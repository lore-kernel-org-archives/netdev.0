From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [v2] rtlwifi: use s8 instead of char
Date: Wed, 29 Jun 2016 15:48:57 +0000 (UTC)
Message-ID: <20160629154857.E131B611F1@smtp.codeaurora.org>
References: <4937395.5geC2TFNE0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4937395.5geC2TFNE0@wuerfel>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> Compiling the rtlwifi drivers for ARM with gcc -Wextra warns about lots of
> incorrect code that results from 'char' being unsigned here, e.g.
> 
> realtek/rtlwifi/rc.c:113:18: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8188ee/dm.c:1070:22: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192ce/trx.c:54:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192cu/mac.c:601:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192de/trx.c:53:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192ee/phy.c:1268:12: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8192se/rf.c:150:20: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8723be/dm.c:877:29: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8723be/phy.c:386:16: error: comparison is always true due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/dm.c:1514:38: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/phy.c:1558:11: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/phy.c:386:24: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/rtl8821ae/trx.c:55:12: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> realtek/rtlwifi/stats.c:31:16: error: comparison is always false due to limited range of data type [-Werror=type-limits]
> 
> This patch changes all uses of 'char' in this driver that refer to
> 8-bit integers to use 's8' instead, which is signed on all architectures.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Thanks, 1 patch applied to wireless-drivers-next.git:

08aba42fcc7e rtlwifi: use s8 instead of char

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9179539/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
