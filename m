From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: port CCMP to cryptoapi's CCM driver
Date: Tue, 08 Oct 2013 20:27:45 +0200
Message-ID: <1381256865.13359.14.camel@jlt4.sipsolutions.net>
References: <1381231915-24232-1-git-send-email-ard.biesheuvel@linaro.org>
	 <1381233152.13359.10.camel@jlt4.sipsolutions.net>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B737B@saturn3.aculab.com>
	 <23D74823-0DE3-4A87-9E89-310F437A328D@linaro.org>
	 <1381239908.13359.12.camel@jlt4.sipsolutions.net>
	 <1381239951.13359.13.camel@jlt4.sipsolutions.net>
	 <CAKv+Gu8D_7d=u1PGWuxoLEETHe8uJMby3K98uQWQn7tk=t_t_w@mail.gmail.com>
	 (sfid-20131008_165219_112466_04B623B7)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>,
	"<linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"<patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>" <patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Ard Biesheuvel <ard.biesheuvel-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKv+Gu8D_7d=u1PGWuxoLEETHe8uJMby3K98uQWQn7tk=t_t_w-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20131008_165219_112466_04B623B7)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-10-08 at 16:52 +0200, Ard Biesheuvel wrote:

> However, personally I don't think this should be necessary and in fact
> my patch removes a stack allocation of u8[48] (from
> ieee80211_crypto_ccmp_decrypt() and from ccmp_encrypt_skb() in wpa.c)
> so it does even out a bit.

I tend to agree.

johannes

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
