From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [V3] mt7601u: do not free dma_buf when ivp allocation fails
Date: Mon,  7 Mar 2016 12:39:54 +0000 (UTC)
Message-ID: <20160307123954.A86A06067A@smtp.codeaurora.org>
References: <1456442667-19751-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jakub Kicinski <kubakici@wp.pl>,
	Matthias Brugger <matthias.bgg@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:50939 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbcCGMjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 07:39:55 -0500
In-Reply-To: <1456442667-19751-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Colin Ian King <colin.king@canonical.com>
> 
> If the allocation of ivp fails the error handling attempts to
> free an uninitialized dma_buf; this data structure just contains
> garbage on the stack, so the freeing will cause issues when the
> urb, buf and dma fields are free'd. Fix this by not free'ing the
> dma_buf if the ivp allocation fails.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
