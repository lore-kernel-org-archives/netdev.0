From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: thunder: Fix crash upon shutdown after failed
 probe
Date: Mon, 16 Nov 2015 09:27:00 -0500 (EST)
Message-ID: <20151116.092700.699331527594997509.davem@davemloft.net>
References: <1447680146-8680-1-git-send-email-p.fedin@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgoutham@cavium.com, rric@kernel.org,
	youngmin.lee@cavium.com, kin-yip.liu@cavium.com
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361AbbKPO1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 09:27:02 -0500
In-Reply-To: <1447680146-8680-1-git-send-email-p.fedin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Mon, 16 Nov 2015 16:22:26 +0300

> If device probe fails, driver remains bound to the PCI device. However,
> driver data has been reset to NULL. This causes crash upon dereferencing
> it in nicvf_remove()
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>
> ---
> v1 => v2:
> - Do the test in nicvf_remove(), this allows to cover more situations

Please send me a relative fix on top of the other change, rather
than a complete replacement patch.
