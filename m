From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC PATCH net-next v2 0/5] netns: allow to identify peer netns
Date: Fri, 26 Sep 2014 12:34:16 -0700
Message-ID: <87mw9myy4n.fsf@x220.int.ebiederm.org>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
	<CAHA+R7NnBJ=T3sukzzp-OD2am1nd318XbrXCX84LfSL=nu9ojw@mail.gmail.com>
	<54228D87.3070309@6wind.com>
	<CAHA+R7NfJYzCsZx0E9YVXKVCQbCm_thPSi+80tix8Z9nVA82Ug@mail.gmail.com>
	<5422F0F4.6000709@6wind.com>
	<CAHA+R7Ot2kLHb+ne5AW3bFNc87qkFOiEHEyDh9sFrsHqXgrY3g@mail.gmail.com>
	<5423D80B.9060500@6wind.com>
	<CAHA+R7Ooyam2L-QfP-TjMEZEOqrQcQDxYiebmw760kgEji4G=g@mail.gmail.com>
	<54256CCB.4000709@6wind.com> <5425BB3E.10700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
To: David Ahern <lxhacker68-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5425BB3E.10700-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> (David Ahern's message of "Fri, 26 Sep
	2014 13:15:10 -0600")
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Ahern <lxhacker68-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On 9/26/14, 7:40 AM, Nicolas Dichtel wrote:
>>>
>>>
>>> No, I don't want to monitor anything. Even if I wanted, I would just
>>> start one
>>> daemon in each netns instead of one for all.
>> Ok you don't want, but some other people (not only me) want it! And
>> having one
>> daemon per netns does not scale: there are scenarii with thousand netns
>> which
>> are dynamically created and deleted.
>
> An example of the scaling problem using quagga (old but still seems to be a
> relevant data point):
>
>
> https://lists.quagga.net/pipermail/quagga-users/2010-February/011351.html
>
> "2k VRFs that would be 2.6G"
>
> And that does not include the overhead of each namespace -- roughly
> 200kB/namespace on one kernel I checked (v3.10). So that's a ballpark of 3G of
> memory.

Resetting the conversation just a little bit.

When I wrote the "ip netns" support I never expected that all
applications would want to run in a specific network namespace.  All
that is needed is one socket per network namespace.

Furthermore one socket or one procesess per network namespaces is
completely orthogonal to the patches presented.  I do not see a
identifying where the far end of a veth pair or similar set of
networking objects as anything that even closely resembles a path to a
using only a single socket.

So I think this whole subthread is quite silly and grossly off track.

Eric
