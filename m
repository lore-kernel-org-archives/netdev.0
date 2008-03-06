From: David Brownell <david-b@pacbell.net>
Subject: Re: [RE(*2)SEND/patch 2.6.25-rc2-git] net/enc28j60: oops fix
Date: Wed, 5 Mar 2008 19:05:23 -0800
Message-ID: <200803051905.23756.david-b@pacbell.net>
References: <20080206173342.21CDF8E152@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <200803041717.32868.david-b@pacbell.net> <20080305.185216.113979641.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lanconelli.claudio@eptar.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp118.sbc.mail.sp1.yahoo.com ([69.147.64.91]:29311 "HELO
	smtp118.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754719AbYCFDFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 22:05:25 -0500
In-Reply-To: <20080305.185216.113979641.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 March 2008, David Miller wrote:
> From: David Brownell <david-b@pacbell.net>
> Date: Tue, 4 Mar 2008 17:17:32 -0800
> 
> > Seems the enc28j60 patches didn't get picked up, ergo (2x) resend...
> > they're not in net-2.6.git, even this oops fix (which I'd expect
> > would be prioritized for 2.6.25)
> 
> We prioritize them about the same as bootup hard hangs with EHCI.

I don't know about any of those that are unfixed ...


> > Subject: [RE(*2)SEND/patch 2.6.25-rc2-git] net/enc28j60: oops fix
> > 
> > Prevent oops on enc28j60 packet RX:  make sure buffers are aligned.
> > Not all architectures support unaligned accesses in kernel space.
> > 
> > Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
> > Acked-by: Claudio Lanconelli <lanconelli.claudio@eptar.com>
> 
> Applied.

Thanks.

