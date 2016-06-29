From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [1/8] wireless: airo: rename 'register' variable
Date: Wed, 29 Jun 2016 15:56:43 +0000 (UTC)
Message-ID: <20160629155643.6DD4B61372@smtp.codeaurora.org>
References: <20160616135245.3198419-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Ondrej Zary <linux-ZCIryABCsrmttCpgsWEBFmD2FQJk+8+b@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160616135245.3198419-1-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> 'register' is a keyword in C and cannot be used in place of a
> variable name, as shown by this -Wextra warning:
> 
> drivers/net/wireless/cisco/airo.c:1105:29: error: 'register' is not at beginning of declaration [-Werror=old-style-declaration]
> 
> This replaces the 'register' keyword with a 'reg' identifier in
> the declaration, which matches the definition and has the intended
> meaning.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>

Thanks, 3 patches applied to wireless-drivers-next.git:

88e97c32068f wireless: airo: rename 'register' variable
2a063835ce7c wireless: brcmsmac: fix old-style declaration
6f07e0f12a57 wireless: ipw2200: fix old-style declaration

-- 
Sent by pwcli
https://patchwork.kernel.org/patch/9180951/

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
