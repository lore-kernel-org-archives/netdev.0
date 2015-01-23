From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi/rtl8192de: remove redundant else if check
Date: Fri, 23 Jan 2015 17:31:01 +0000 (UTC)
Message-ID: <20150123173101.2E01C1416F0@smtp.codeaurora.org>
References: <1421158054-22566-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421158054-22566-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> From: Colin Ian King <colin.king@canonical.com>
> 
> The else if check condition checks for the opposite of the
> if check, hence the else if check is redundant and can be
> replaced with a simple else:
> 
> if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
> 	..
> } else if (rtlpriv->rtlhal.macphymode != SINGLEMAC_SINGLEPHY) {
> 	..
> }
> 
> replaced with:
> 
> if (rtlpriv->rtlhal.macphymode == SINGLEMAC_SINGLEPHY) {
> 	..
> } else {
> 	..
> }
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks, applied to wireless-drivers-next.git.

Kalle Valo
