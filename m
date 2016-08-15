From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: thunderx: Remove unnecessary
 pci_set_drvdata()
Date: Mon, 15 Aug 2016 16:35:03 -0700 (PDT)
Message-ID: <20160815.163503.1779445142068275986.davem@davemloft.net>
References: <1471301489-24888-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbcHOXfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 19:35:04 -0400
In-Reply-To: <1471301489-24888-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 15 Aug 2016 22:51:29 +0000

> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>

Applied.
