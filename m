From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][BNX2]: Disable MSI on 5706 if AMD 8132 bridge is
 present
Date: Fri, 29 Sep 2006 15:49:17 -0700 (PDT)
Message-ID: <20060929.154917.125894679.davem@davemloft.net>
References: <1159564053.3741.19.camel@rh4>
	<451D9007.6010905@garzik.org>
	<1159565963.3741.23.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:4019
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932150AbWI2WtP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 18:49:15 -0400
To: mchan@broadcom.com
In-Reply-To: <1159565963.3741.23.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 29 Sep 2006 14:39:23 -0700

> On Fri, 2006-09-29 at 17:28 -0400, Jeff Garzik wrote:
> > Michael Chan wrote:
> > > AMD believes this incompatibility is unique to the 5706, and
> > > prefers to locally disable MSI rather than globally disabling it
> > > using pci_msi_quirk.
> > 
> > Why is it unique to the 5706?  Is this just a guess on AMD and 
> > Broadcom's part?
> > 
> I just took AMD's word for it.  It doesn't matter to me whether we
> disable it locally or globally.  Since this is AMD's bridge, I just
> follow their recommendation.  They probably haven't seen this issue on
> any other devices except ours.

I really think this is a reasonable thing to do.

It's absolutely rediculious to disable MSI for every card just
because one decided to use a masked 64-bit transaction for
what's supposed to be a 32-bit one.

Jeff, I totally understand your knee-jerk reaction to per-device MSI
validation checks, but in this case I find that knee-jerk reaction
to be totally unreasonable. :-)

