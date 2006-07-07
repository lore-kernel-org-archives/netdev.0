From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 7 Jul 2006 12:51:35 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BD9B@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:38926 "EHLO
	mms1.broadcom.com") by vger.kernel.org with ESMTP id S932293AbWGGTv7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 15:51:59 -0400
Content-class: urn:content-classes:message
To: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:

> Add the AMD 8131 bridge to the list of chipsets that reorder writes.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>

Hi John,

The latest tg3 driver in 2.6.18 has a recovery mechanism to detect
and recover from this kind of reordering problem.  I suppose we can
add this chipset now if we're reasonably sure that it is reordering
MMIO.  But it will be nice to actually see the recovery mechanism in
action catching this chipset.

