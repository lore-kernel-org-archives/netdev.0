From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] irda: vlsi_ir: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 18:10:20 -0500 (EST)
Message-ID: <20131209.181020.1892971270357248787.davem@davemloft.net>
References: <000801cef48e$ba4f5de0$2eee19a0$%han@samsung.com>
	<000901cef48e$d1dda3e0$7598eba0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: jg1.han@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755975Ab3LIXKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 18:10:21 -0500
In-Reply-To: <000901cef48e$d1dda3e0$7598eba0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jingoo Han <jg1.han@samsung.com>
Date: Mon, 09 Dec 2013 12:29:08 +0900

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Applied.
