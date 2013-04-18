From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH V6] Bundle fixes for Xen netfront / netback
Date: Thu, 18 Apr 2013 02:20:41 +0100
Message-ID: <20130418012041.GH5815@zion.uk.xensource.com>
References: <1366220523-14579-1-git-send-email-wei.liu2@citrix.com>
 <20130417193119.GA22059@phenom.dumpdata.com>
 <20130417194317.GG5815@zion.uk.xensource.com>
 <20130417.172120.668924175922610397.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"wdauchy@gmail.com" <wdauchy@gmail.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:55823 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935603Ab3DRBUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Apr 2013 21:20:42 -0400
Content-Disposition: inline
In-Reply-To: <20130417.172120.668924175922610397.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 17, 2013 at 10:21:20PM +0100, David Miller wrote:
> From: Wei Liu <wei.liu2@citrix.com>
> Date: Wed, 17 Apr 2013 20:43:17 +0100
> 
> > On Wed, Apr 17, 2013 at 08:31:19PM +0100, Konrad Rzeszutek Wilk wrote:
> >> On Wed, Apr 17, 2013 at 06:41:59PM +0100, Wei Liu wrote:
> >> > Final round of this series. All acked and ready to go in.
> >> 
> >> Should you put CC: stable@vger.kernel.org on some of them?
> > 
> > I don't think so: Ian Campbell told me that DaveM would like the patches
> > to go through his tree.
> 
> That's rather irrelevant.

Sorry I'm still learning the process of doing netdev. If you can
straighten it out for me that would be very helpful.

The handle I have is:
http://marc.info/?l=xen-devel&m=136552034026257&w=2

QUOTE
"> This should probably also CC stable@vger.kernel.org

DaveM prefers net patches to not do so and he takes care of forwarding
patches once he is happy (i.e. after they've been in his/Linus' tree for
a bit)."
/QUOTE

But it seems that Ian got you wrong. Or I misunderstood him.

So this patch series is considered both for net-next and stable because
it is basement for our future development and we would also like it to
get backported to stable. What should I do with it? Should I rebase it
against net-next or net? Or should I send out two series against
different branches?

Furthur question, now that I know there is actually two branches for
network related development, should I explicitly point out which branch
my series is against in the future?

Thank you for your time. :-)


Wei.
