From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: libertas: Add spinlock to avoid race condition
Date: Wed, 29 Jun 2016 15:47:12 +0000 (UTC)
Message-ID: <20160629154712.95563613CE@smtp.codeaurora.org>
References: <1465990443-19738-1-git-send-email-andrianov@ispras.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Andrianov <andrianov@ispras.ru>,
	libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org, vaishali.thakkar@oracle.com
To: Pavel Andrianov <andrianov@ispras.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:39623 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752660AbcF2Pr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 11:47:28 -0400
In-Reply-To: <1465990443-19738-1-git-send-email-andrianov@ispras.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Andrianov <andrianov@ispras.ru> wrote:
> lbs_mac_event_disconnected may free priv->currenttxskb
> while lbs_hard_start_xmit accesses to it.
> The patch adds a spinlock for mutual exclusion.
> 
> Tested on OLPC XO-1 (usb8388) and XO-1.5 (sd8686) with v4.7-rc3.
> 
> Confirmed that lbs_mac_event_disconnected is being called on the
> station when hostapd on access point is given SIGHUP.
> 
> Signed-off-by: Pavel <andrianov@ispras.ru>
> Tested-by: James Cameron <quozl@laptop.org>
> Acked-by: Vaishali Thakkar <vaishali.thakkar@oracle.com>

Thanks, 1 patch applied to wireless-drivers-next.git:

f52b041aed77 libertas: Add spinlock to avoid race condition

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9178477/
