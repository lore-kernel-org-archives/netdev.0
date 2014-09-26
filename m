From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Fri, 26 Sep 2014 19:20:57 +0400
Message-ID: <54258459.8020803@msgid.tls.msk.ru>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru> <542183A6.4070207@msgid.tls.msk.ru> <20140923143124.GC19016@ubuntu-hedt> <54219984.2080601@msgid.tls.msk.ru> <5421AF5C.6000106@broadcom.com> <5421B78E.4050908@msgid.tls.msk.ru> <5422C6E0.3080002@broadcom.com> <8d3f6516-9578-406c-9444-6fe1ba982ea6@email.android.com> <54257779.8010903@msgid.tls.msk.ru> <54257B69.3070607@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <54257B69.3070607-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

26.09.2014 18:42, Arend van Spriel wrote:

> Being bold here, but would you be willing to send that non-working part of hardware to me. I seem to have 4313 cards over here that just work and it would help greatly investigating the issue. I guess you do not care that much anymore, but might be others do (myself included).

Please note that this is 2nd card of the same model which I
come across in different laptops (one lenovo which I bought
last December, and later in a HP Envy which I borrowed from
my friend because my lenovo didn't work anymore).  Both shows
exactly the same sympthoms, on several different WiFi networks.
The sympthoms are rehashed here several times -- sporaric stalls
of different frequence of occurences, which can be cured by
re-loading the driver.

I can send it your way, -- guess it will be quite a bit costly,
but I don't have any use for it anyway (short of throwing it
away), and since I already spent significantly more money due
to all this (whole thinkpad plus ssds and several wifi adaptors),
this additional cost is just a small noize.  But since that's
2nd card in a row, maybe there's something else in there, the
prob is not in the card?

I mentioned several times that here, both of these cards worked
for long periods of time and for many gigabytes transfers (I
used wget in a loop overnight), -- and worked very well.  Just
that these "working periods" changes into "non-working periods"
without any clear cause, sporadically.  And these working
periods can be rather long, too.

Maybe this is some uninitialized field somewhere, I dunno -
at least that'd explain the "mystery" and inability to reproduce
any of the two kinds of "periods".  Ofcourse it's rather difficult
to debug, but it might not be card-specific.

I also noticed that quite often it does not work after rebooing
the laptop from windows.  But not always. I thought maybe win
switches it into some mode which linux driver fails to notice,
but no, the fact that it sometimes works after windows tells
me that I'm not right.

And note please that the closed-source wl driver always worked
with both of these cards, at least when I was able to compile
it (the prob is always the same - no support for more recent
kernels; and I don't really like to use recent kernels (I myself
currently stay with 3.10.x stable line), but both laptops actually
requires recent kernels to work properly (either because of
great energy saving support in latest intel cpus, or because of
support of gpu in latest intel celerons) -- that's why I really
prefer in-kernel driver).

That to say - the fact that wl always works may tell that the
hw is fine and the prob is elsewhere.

Thanks,

/mjt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
