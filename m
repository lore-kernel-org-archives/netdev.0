From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 timeouts with 2.6.17-rc6
Date: Fri, 16 Jun 2006 20:37:17 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BD1E@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: jk@blackdown.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:35080 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S1751586AbWFQDh3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Jun 2006 23:37:29 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:

> From: "Michael Chan" <mchan@broadcom.com>
> Date: Fri, 16 Jun 2006 18:27:32 -0700
> 
> > In the meantime, I wonder if we should disable TSO by default on the
> > 5780 chip for 2.6.17.
> 
> Sounds reasonable.  Would we disable it for all chips that set
> TG3_FLG2_5780_CLASS or a specific variant?
> 
Yes, let's disable it for all TG3_FLG2_5780_CLASS chips for now
until we figure out what's going on.

