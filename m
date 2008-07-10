From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: RE: [PATCH 3/6] e1000: delete non NAPI code from the driver.
Date: Thu, 10 Jul 2008 15:56:38 -0700
Message-ID: <607183388E5F5E43BD4F44478E62341E034748C9@orsmsx419.amr.corp.intel.com>
References: <20080707.224336.59099363.davem@davemloft.net> <20080708070106.GA30382@electric-eye.fr.zoreil.com> <20080708.015548.127198943.davem@davemloft.net> <20080710223143.GC31019@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <jeff@garzik.org>, <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "Francois Romieu" <romieu@fr.zoreil.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47943 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754664AbYGJW4k convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 18:56:40 -0400
Content-class: urn:content-classes:message
In-reply-to: <20080710223143.GC31019@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Francois Romieu [mailto:romieu@fr.zoreil.com]
>Sent: Thursday, July 10, 2008 3:32 PM
>To: David Miller
>Cc: jeff@garzik.org; netdev@vger.kernel.org; Kirsher, Jeffrey T;
>Brandeburg, Jesse; Allan, Bruce W; Waskiewicz Jr, Peter P; Ronciak,
John
>Subject: [PATCH 3/6] e1000: delete non NAPI code from the driver.
>
>Compile-tested only.
>
>Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
>---
> Documentation/networking/e1000.txt |   14 +---
> drivers/net/Kconfig                |   14 ----
> drivers/net/e1000/e1000.h          |   11 +--
> drivers/net/e1000/e1000_main.c     |  150
+++-----------------------------
>---
> 4 files changed, 17 insertions(+), 172 deletions(-)
>

I will pull this into my e1000 queue.  I have several other e1000
cleanup patches also, so I put push this out with my other patches
before this weekend.

Cheers,
Jeff
