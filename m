From: "David S. Miller" <davem@davemloft.net>
Subject: Re: BUG: dst underflow (again)
Date: Thu, 4 Nov 2004 23:14:33 -0800
Message-ID: <20041104231433.3a7233e8.davem@davemloft.net>
References: <4178AB0D.6060107@pobox.com>
	<20041022.155159.98771450.yoshfuji@linux-ipv6.org>
	<20041022075947.GA15795@xi.wantstofly.org>
	<1099577717.1039.155.camel@jzny.localdomain>
	<20041104221801.584c8f11.davem@davemloft.net>
	<418B2645.6080404@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, buytenh@wantstofly.org, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <418B2645.6080404@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 05 Nov 2004 02:05:41 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> David S. Miller wrote:
> > Jeff, could you similarly decode the ones that you seem to get?
> > That would be an incredibly useful datapoint.  If you've provided
> > this already, my bad and please point me at where you posted that.
> 
> I've compiled IPv6 into my router's kernel image, so next time I reboot, 
> I should be able to get at symbol info out of the BUGs a bit more easily.

Thanks a lot.

> > But let me ask, do you have any IPSEC policies in the kernel
> > when these BUGs trigger?  If so, I'm pretty sure I know what
> > the problem may be.
> 
> I know this question wasn't directed at me, but, I do always compile 
> ipsec stuff into my kernel, in addition to netfilter.  The relevant 
> options are attached for the curious.

Yes, but do you actually install any IPSEC rules into your system?

The only way xfrm_lookup() can ever fall (and call that BUG'ing
dst_release() in udpv6_sendmsg()) is if you have at least some
IPSEC policies configured.
