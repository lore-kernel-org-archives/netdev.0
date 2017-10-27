From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: rtlwifi: Convert timers to use timer_setup()
Date: Fri, 27 Oct 2017 07:42:44 +0000 (UTC)
Message-ID: <20171027074244.B7F7F601DA@smtp.codeaurora.org>
References: <20171024092829.GA47013@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        Ping-Ke Shih <pkshih@realtek.com>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024092829.GA47013@beast>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kees Cook <keescook@chromium.org> wrote:

> In preparation for unconditionally passing the struct timer_list pointer to
> all timer callbacks, switch to using the new timer_setup() and from_timer()
> to pass the timer pointer explicitly.
> 
> Cc: Kalle Valo <kvalo@codeaurora.org>
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Chaoming Li <chaoming_li@realsil.com.cn>
> Cc: Ping-Ke Shih <pkshih@realtek.com>
> Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: linux-wireless@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Signed-off-by: Kees Cook <keescook@chromium.org>

Patch applied to wireless-drivers-next.git, thanks.

7c51d17c027e rtlwifi: Convert timers to use timer_setup()

-- 
https://patchwork.kernel.org/patch/10023861/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
