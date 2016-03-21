From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 4/5] ath9k: fix misleading indentation
Date: Mon, 21 Mar 2016 16:24:31 +0200
Message-ID: <87h9fzhpsw.fsf@purkki.adurom.net>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
	<1457965120-3155420-5-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57525 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755409AbcCUOYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 10:24:36 -0400
In-Reply-To: <1457965120-3155420-5-git-send-email-arnd@arndb.de> (Arnd
	Bergmann's message of "Mon, 14 Mar 2016 15:18:37 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> A cleanup patch in linux-3.18 moved around some code in the ath9k
> driver and left some code to be indented in a misleading way,
> made worse by the addition of some new code for p2p mode, as
> discovered by a new gcc-6 warning:
>
> drivers/net/wireless/ath/ath9k/init.c: In function 'ath9k_set_hw_capab':
> drivers/net/wireless/ath/ath9k/init.c:851:4: warning: statement is indented as if it were guarded by... [-Wmisleading-indentation]
>     hw->wiphy->iface_combinations = if_comb;
>     ^~
> drivers/net/wireless/ath/ath9k/init.c:847:3: note: ...this 'if' clause, but it is not
>    if (ath9k_is_chanctx_enabled())
>    ^~
>
> The code is in fact correct, but the indentation is not, so I'm
> reformatting it as it should have been after the original cleanup.
>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: 499afaccf6f3 ("ath9k: Isolate ath9k_use_chanctx module parameter")
> Fixes: eb61f9f623f7 ("ath9k: advertise p2p dev support when chanctx")

Dave already applied this so I can skip this.

-- 
Kalle Valo
