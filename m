From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: ipw2x00: add checks for dma mapping errors
Date: Thu,  7 Jan 2016 09:19:20 +0000 (UTC)
Message-ID: <20160107091920.1353E605BF@smtp.codeaurora.org>
References: <1451689958-8005-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: Alexey Khoroshilov <khoroshilov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:48869 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbcAGJTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 04:19:21 -0500
In-Reply-To: <1451689958-8005-1-git-send-email-khoroshilov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> ipw2100_alloc_skb() and ipw2100_tx_send_data() do not check if mapping
> dma memory succeed. The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
