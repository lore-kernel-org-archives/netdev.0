From: "David S. Miller" <davem@redhat.com>
Subject: Re: TCP IP Offloading Interface
Date: Sun, 13 Jul 2003 16:02:00 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030713160200.571716cf.davem@redhat.com>
References: <ODEIIOAOPGGCDIKEOPILCEMBCMAA.alan@storlinksemi.com>
	<20030713004818.4f1895be.davem@redhat.com>
	<52u19qwg53.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: alan@storlinksemi.com, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <52u19qwg53.fsf@topspin.com>
List-Id: netdev.vger.kernel.org

On 13 Jul 2003 09:22:32 -0700
Roland Dreier <roland@topspin.com> wrote:

>     David> TOE is evil, read this:
> 
>     David> http://www.usenix.org/events/hotos03/tech/full_papers/mogul/mogul.pdf

> Your ideas are certainly very interesting, and I would be happy to see
> hardware that supports flow identification.  But the Usenix paper
> you're citing completely disagrees with you!

I didn't say I agree with all of Moguls ideas, just his anti-TOE
arguments.  For example, I also think RDMA sucks too yet he thinks
it's a good iea.

>  For example, Mogul writes:
> 
>  "Nevertheless, copy-avoidance designs have not been widely adopted,
>   due to significant limitations. For example, when network maximum
>   segment size (MSS) values are smaller than VM page sizes, which is
>   often the case, page-remapping techniques are insufficient (and
>   page-remapping often imposes overheads of its own.)"

On send this doesn't matter, on receive you use my clever receive
buffer handling + flow cache idea to accumulate the data portion of
packets into page sized chunks for the networking to flip.

You obviously don't understand my ideas if you think that it matters
whether there is some relationship between the MTU and the system
page size necessary for the scheme to work.
