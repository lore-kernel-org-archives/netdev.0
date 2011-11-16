From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: cache-in compressed fw image
Date: Wed, 16 Nov 2011 17:48:33 -0500 (EST)
Message-ID: <20111116.174833.1324461996830325353.davem@davemloft.net>
References: <1321394853-14807-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57719 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754128Ab1KPWsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 17:48:36 -0500
In-Reply-To: <1321394853-14807-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Wed, 16 Nov 2011 00:07:33 +0200

> Re-request fw from fs may fail for different reasons, once the fw was
> loaded we won't release it until driver is removed.
> 
> This also resolves the boot problem when initial fw is located on initrd,
> but rootfs is still unavailable, in this case device reset will fail due
> to absence of fw files.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Applied.
