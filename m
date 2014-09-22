From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Work around HW/FW limitations with vlan
 encapsulated frames
Date: Mon, 22 Sep 2014 14:20:50 -0400 (EDT)
Message-ID: <20140922.142050.1675487445764875212.davem@davemloft.net>
References: <1411050677-28147-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com, prashant@broadcom.com,
	mchan@broadcom.com
To: vyasevich@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754466AbaIVSUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 14:20:53 -0400
In-Reply-To: <1411050677-28147-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevich@gmail.com>
Date: Thu, 18 Sep 2014 10:31:17 -0400

> TG3 appears to have an issue performing TSO and checksum offloading
> correclty when the frame has been vlan encapsulated (non-accelrated).
> In these cases, tcp checksum is not correctly updated.
> 
> This patch attempts to work around this issue.  After the patch,
> 802.1ad vlans start working correctly over tg3 devices.
> 
> CC: Prashant Sreedharan <prashant@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>

Applied and queued up for -stable.
