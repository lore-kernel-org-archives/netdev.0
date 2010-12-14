From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next] if_ether.h: Add #define ETH_P_LARQ for
 HPNA/LARQ
Date: Mon, 13 Dec 2010 19:53:51 -0800
Message-ID: <1292298831.26970.263.camel@Joe-Laptop>
References: <1292287667.26970.114.camel@Joe-Laptop>
	 <20101214014920.GA2453@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Brett Rudley <brudley@broadcom.com>,
	Dowan Kim <dowan@broadcom.com>, arend@broadcom.com,
	rvossen@broadcom.com
To: Henry Ptasinski <henryp@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2638 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757161Ab0LNDxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 22:53:53 -0500
In-Reply-To: <20101214014920.GA2453@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-13 at 17:49 -0800, Henry Ptasinski wrote:
> On Mon, Dec 13, 2010 at 04:47:47PM -0800, Joe Perches wrote:
> > LARQ seems to be used by Broadcom's staging driver.
> > Might as well add a #define for it to the normal location.
> > diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
[]
> > +#define ETH_P_LARQ	0x886c		/* HPNA / Broadcom
> That should be ETH_P_BRCM (or ETH_P_EPIGRAM).  HPNA/ILCP used a range of
> subtypes for LARQ and other HPNA protocols.  The brcmfmac driver uses a
> different subypte for encapsulating some event signals between the device and
> the host, but doesn't implement any of the HPNA protocols.

Another choice might be ETH_P_LINK_CTL


