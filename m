From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH v3] mac80211: port CCMP to cryptoapi's CCM driver
Date: Fri, 11 Oct 2013 15:44:16 +0200
Message-ID: <1381499056.14293.19.camel@jlt4.sipsolutions.net>
References: <1381391720-28771-1-git-send-email-ard.biesheuvel@linaro.org>
	 (sfid-20131010_095705_907290_11D45849)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1381391720-28771-1-git-send-email-ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org> (sfid-20131010_095705_907290_11D45849)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-10-10 at 09:55 +0200, Ard Biesheuvel wrote:
> Use the generic CCM aead chaining mode driver rather than a local
> implementation that sits right on top of the core AES cipher.
> 
> This allows the use of accelerated implementations of either
> CCM as a whole or the CTR mode which it encapsulates.

Applied.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
