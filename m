From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH] ath6kl: remove redundant null pointer check on send_pkt
Date: Fri, 09 Oct 2015 11:47:14 +0300
Message-ID: <874mi0sa25.fsf@kamboji.qca.qualcomm.com>
References: <1441633745-5755-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441633745-5755-1-git-send-email-colin.king@canonical.com>
	(Colin King's message of "Mon, 7 Sep 2015 14:49:05 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Colin King <colin.king@canonical.com> writes:

> From: Colin Ian King <colin.king@canonical.com>
>
> The check for send_pkt being NULL is redundant before the call
> to htc_reclaim_txctrl_buf, therefore it should be removed. This was
> detected by static analysis by cppcheck.
>
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.

-- 
Kalle Valo
