From: "Henry Ptasinski" <henryp@broadcom.com>
Subject: Re: [RFC PATCH net-next] if_ether.h: Add #define ETH_P_LARQ for
 HPNA/LARQ
Date: Wed, 15 Dec 2010 13:22:07 -0800
Message-ID: <20101215212207.GA2548@broadcom.com>
References: <1292287667.26970.114.camel@Joe-Laptop>
 <20101214014920.GA2453@broadcom.com>
 <1292298831.26970.263.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Brett Rudley" <brudley@broadcom.com>,
	"Dowan Kim" <dowan@broadcom.com>,
	"Arend Van Spriel" <arend@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4285 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819Ab0LOVWT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 16:22:19 -0500
In-Reply-To: <1292298831.26970.263.camel@Joe-Laptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 07:53:51PM -0800, Joe Perches wrote:
> On Mon, 2010-12-13 at 17:49 -0800, Henry Ptasinski wrote:
> > On Mon, Dec 13, 2010 at 04:47:47PM -0800, Joe Perches wrote:
> > > LARQ seems to be used by Broadcom's staging driver.
> > > Might as well add a #define for it to the normal location.
> > > diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
> []
> > > +#define ETH_P_LARQ	0x886c		/* HPNA / Broadcom
> > That should be ETH_P_BRCM (or ETH_P_EPIGRAM).  HPNA/ILCP used a range of
> > subtypes for LARQ and other HPNA protocols.  The brcmfmac driver uses a
> > different subypte for encapsulating some event signals between the device and
> > the host, but doesn't implement any of the HPNA protocols.
> 
> Another choice might be ETH_P_LINK_CTL
> 

That would be fine too.

- Henry

