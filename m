From: Kalle Valo <kvalo-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org>
Subject: Re: ath10k: replace config_enabled() with IS_REACHABLE()
Date: Fri, 2 Sep 2016 17:57:30 +0200
Message-ID: <388c99a317f2431596e43d0feee204c9@euamsexm01a.eu.qualcomm.com>
References: <1471969646-13119-1-git-send-email-yamada.masahiro@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <ath10k-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Masahiro Yamada" <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1471969646-13119-1-git-send-email-yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org> wrote:
> Commit 97f2645f358b ("tree-wide: replace config_enabled() with
> IS_ENABLED()") mostly did away with config_enabled().
> 
> This is one of the postponed TODO items as config_enabled() is used
> for a tristate option here.  Theoretically, config_enabled() is
> equivalent to IS_BUILTIN(), but I guess IS_REACHABLE() is the best
> fit for this case because both CONFIG_HWMON and CONFIG_ATH10K are
> tristate.
> 
> Signed-off-by: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>

Thanks, 1 patch applied to ath-next branch of ath.git:

749bc03ae2cd ath10k: replace config_enabled() with IS_REACHABLE()

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9295945/
