From: Maxime Bizon <mbizon@freebox.fr>
Subject: Re: tg3_close question
Date: Thu, 09 Nov 2006 18:33:46 +0100
Message-ID: <1163093626.19540.4.camel@sakura.staff.proxad.net>
References: <1551EAE59135BE47B544934E30FC4FC093FCCE@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <1551EAE59135BE47B544934E30FC4FC093FCCF@NT-IRVA-0751.brcm.ad.broadcom.com>
	 <5cac192f0611090907v7b3f19m6916dcdba143996f@mail.gmail.com>
	 <5cac192f0611090922x7b6f8369of5bf294e9768800d@mail.gmail.com>
Reply-To: mbizon@freebox.fr
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sakura.staff.proxad.net ([213.228.1.107]:32453 "EHLO
	sakura.staff.proxad.net") by vger.kernel.org with ESMTP
	id S1424167AbWKIRdv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 12:33:51 -0500
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f0611090922x7b6f8369of5bf294e9768800d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thu, 2006-11-09 at 18:22 +0100, Eric Lemoine wrote:

> Actually I don't understand the purpose of having dev_close() wait for
> __LINK_STATE_RX_SCHED to be cleared. An interrupt may arrive at any
> time after it's cleared, and reset __LINK_STATE_RX_SCHED. Can someone
> explain please?

Further interrupts won't schedule poll because netif_rx_schedule_prep()
checks for netif_running().

-- 
Maxime
