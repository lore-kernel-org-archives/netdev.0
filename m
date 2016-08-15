From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: ena: Remove unnecessary pci_set_drvdata()
Date: Mon, 15 Aug 2016 16:34:53 -0700 (PDT)
Message-ID: <20160815.163453.730513336963037815.davem@davemloft.net>
References: <1471301434-24531-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netanel@annapurnalabs.com, saeed@annapurnalabs.com,
	zorik@annapurnalabs.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbcHOXe6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 19:34:58 -0400
In-Reply-To: <1471301434-24531-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 15 Aug 2016 22:50:34 +0000

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
