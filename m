From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Fix usage of netif_*_all_queues() with	netif_carrier_{off|on}()
Date: Tue, 11 Nov 2008 03:33:45 -0500
Message-ID: <49194369.7030902@garzik.org>
References: <20081107221608.13396.10693.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36975 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754715AbYKKIds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Nov 2008 03:33:48 -0500
In-Reply-To: <20081107221608.13396.10693.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher wrote:
> From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> 
> netif_carrier_off() is sufficient to stop Tx into the driver.  Stopping the Tx
> queues is redundant and unnecessary.  By the same token, netif_carrier_on()
> will be sufficient to re-enable Tx, so waking the queues is unnecessary.

Is this a fix as the subject says (2.6.28), or an optimization as the 
description implies (2.6.29)?

AFAICS from a quick glance, things are not actually _broken_, are they?

	Jeff



