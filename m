From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] bnx2x: Prevent link flaps when booting
 from SAN.
Date: Fri, 07 Dec 2012 12:54:18 -0500 (EST)
Message-ID: <20121207.125418.1997064815507310315.davem@davemloft.net>
References: <1354784643-22236-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, barak@broadcom.com,
	eilong@broadcom.com
To: yuvalmin@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56981 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423536Ab2LGRyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:54:21 -0500
In-Reply-To: <1354784643-22236-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yuval Mintz" <yuvalmin@broadcom.com>
Date: Thu, 6 Dec 2012 11:04:03 +0200

> From: Barak Witkowski <barak@broadcom.com>
> 
> It is possible that the driver is configured to operate with a certain
> link configuration which differs from the link's configuration during
> boot from SAN - this would cause the driver to flap the link.
> 
> Said flap may be missed by specific switches, causing dcbx convergence 
> to be too long and boot sequence to fail. Convergence is longer because
> switch ignores new dcbx packets due to counters mismatch, as only host 
> side reset the counters due to the link flap.
> 
> This patch causes the driver to ignore user's initial configuration during
> boot from SAN, and continues with the existing link configuration.
> 
> Signed-off-by: Barak Witkowski <barak@broadcom.com>
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied, thanks.
