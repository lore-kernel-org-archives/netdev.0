From: Ben Greear <greearb@candelatech.com>
Subject: Re: do_gettimeofday
Date: Fri, 03 Oct 2003 09:42:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F7DA6EB.4040200@candelatech.com>
References: <3F7C6F3B.6070502@sgi.com> <20031002125625.72b8c0a7.shemminger@osdl.org> <20031003004133.3148c39a.davem@redhat.com> <20031003082642.GF42593@gaz.sfgoth.com> <20031003012754.23de3f66.davem@redhat.com> <20031003084847.GH42593@gaz.sfgoth.com> <20031003015220.7ee6e451.davem@redhat.com> <20031003092617.GI42593@gaz.sfgoth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-Reply-To: <20031003092617.GI42593@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitchell Blank Jr wrote:
> David S. Miller wrote:
> 
>>There is the weird issue (with both the sparc64 example and your's
>>here) of whether we should care about what happens when settimeofday()
>>occurs.  We probably shouldn't worry about it... as it gives weird
>>results even currently.
> 
> 
> Nah.  If anything you'll get better results since you're computing
> the timeval later.
> 
> This is another argument for caching the computation though - otherwise
> a settimeofday() could cause the packet timestamp to change drasically
> from one observation to the next :-)

It would also be nice to be able to set a flag on raw sockets to just have the 'raw' timestamp passed
up to user-space.  In many cases, the relative timestamp may be all that is needed,
and user-space could optimize the conversion to gettimeofday as needed.

Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
