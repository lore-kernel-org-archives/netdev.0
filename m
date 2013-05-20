From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: Fix GSO for 57710/57711 chips
Date: Mon, 20 May 2013 00:57:32 -0700 (PDT)
Message-ID: <20130520.005732.1368878689207038499.davem@davemloft.net>
References: <1368974461-5308-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dmitry@broadcom.com, eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782Ab3ETH5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 May 2013 03:57:34 -0400
In-Reply-To: <1368974461-5308-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Sun, 19 May 2013 17:41:01 +0300

> Starting with commit 91226790bbe2dbfbba48dd79d49f2b38ef10eb97
> `bnx2x: use FW 7.8.17', the bnx2x driver no longer requests the FW to perform
> IP checksums for IPv4 packets.
> 
> This behaviour needs to be revised for 57710/57711 chips -
> when using GSO, if the driver will not set the IP checksum flag then packets
> will be transmitted by the chip without a valid IP checksum, resulting in
> a drop of all such packets on the receiver-side.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
