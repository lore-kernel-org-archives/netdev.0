From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] tg3: add amd8131 to "write reorder" chipsets
Date: Fri, 7 Jul 2006 14:22:11 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093F9B2@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:40198 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S932310AbWGGVWZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 17:22:25 -0400
Content-class: urn:content-classes:message
To: "John W. Linville" <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:

> Obviously it is between you and Dave to decide what is best.  We are
> carrying this patch in RHEL4 at the moment, so I didn't want to hold
> it back from upstream.  If you think you have a better solution then
> "it's on you"... :-)
> 

Since 2.6.18 already has the recovery logic in place, we can probably
holdoff merging this patch upstream.

If e1000 is having similar problems with a similar AMD chipset, it
must be a fairly widespread problem.  It might be a good idea to
push this patch to -stable.

