From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: brcmfmac: only lock and unlock fws if fws is not null
Date: Fri, 11 Dec 2015 11:14:40 +0000 (UTC)
Message-ID: <20151211111440.67B29141A65@smtp.codeaurora.org>
References: <1449056710-9776-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kernel-tram@lists.ubuntu.com, Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	Franky Lin <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Arnd Bergmann <arnd@arndb.de>, linux-wireless@vger.kernel.org,
	brcm80211-dev-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449056710-9776-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Colin Ian King <colin.king@canonical.com>
> 
> There is a null ptr check for fws to set bcmc_credit_check, however,
> there a lock and unlock on fws should only performed if fwts is
> also not null to also avoid a potential null pointer deference.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Acked-by: Arend van Spriel <arend@broadcom.com>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
