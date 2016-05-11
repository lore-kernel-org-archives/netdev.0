From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [v2] rtlwifi: Fix logic error in enter/exit power-save mode
Date: Wed, 11 May 2016 18:44:31 +0000 (UTC)
Message-ID: <20160511184431.23F4D61322@smtp.codeaurora.org>
References: <20160502163835.GA10925@udknight>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: wang yanqing <udknight@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160502163835.GA10925@udknight>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wang yanqing <udknight@gmail.com> wrote:
> In commit a269913c52ad ("rtlwifi: Rework rtl_lps_leave() and
> rtl_lps_enter() to use work queue"), the tests for enter/exit
> power-save mode were inverted. With this change applied, the
> wifi connection becomes much more stable.
> 
> Fixes: a269913c52ad ("rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue")
> Signed-off-by: Wang YanQing <udknight@gmail.com>
> CC: Stable <stable@vger.kernel.org> [3.10+]
> Acked-by: Larry Finger <Larry.Finger@lwfinger.net>

Thanks, 1 patch applied to wireless-drivers-next.git:

873ffe154ae0 rtlwifi: Fix logic error in enter/exit power-save mode

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/8993841/
