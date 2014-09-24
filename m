From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Wed, 24 Sep 2014 18:51:23 +0400
Message-ID: <8d3f6516-9578-406c-9444-6fe1ba982ea6@email.android.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru> <542183A6.4070207@msgid.tls.msk.ru> <20140923143124.GC19016@ubuntu-hedt> <54219984.2080601@msgid.tls.msk.ru> <5421AF5C.6000106@broadcom.com> <5421B78E.4050908@msgid.tls.msk.ru> <5422C6E0.3080002@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5422C6E0.3080002-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


>I looked at the log. I see download commence because the packets 
>received of 1562 bytes length. So within one second I see little over 
>200 packets so approx. 3Mbps which is not impressive but I don't know 
>what can be expected.

When it works it goes 50+ Mbps. I always tested at the same place and the signal there is good. D/load speed is 11Mb/sec steady. When it works. Today after powercycle it worked fine at 11 megabytes per second, I transferred several gigs of data.

> Indeed after that it stalls and we only seem to 
>receive small packets of 179 bytes that seem to end up in 
>cfg80211_mgmt_rx. It could be that the hardware is somehow bogged and 
>can not receive at higher modulations as management frames are 
>transmitted at lower rates. The hardware will drop packets that are 
>having FCS (aka. checksum) errors. The brcmsmac is missing some code to
>
>read fcs error count from hardware, but I will get back to you with a 
>patch that we can use to confirm this.

I see. Today I ordered an intel wifi  card (which also works at 5MHz) and will swap bcm4313 with it. Since the notebook has to be disassembled for this (it doesn't have separate window for wifi card), and the procedure is rather complex I don't want to do it more times than necessary... ;)

Thanks! 

/mjt from android phone
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
