From: Rickard Strandqvist <rickard_strandqvist-IW2WV5XWFqGZkjO+N0TKoMugMpMbD5Xr@public.gmane.org>
Subject: Re: [PATCH] net: wireless: brcm80211: brcmfmac: dhd_sdio.c: Cleaning
 up missing null-terminate in conjunction with strncpy
Date: Sun, 12 Oct 2014 13:05:40 +0200
Message-ID: <CAFo99gY9dyzhuJe4LwiJKgRwLRU+uVKzLpscFrZw_xZDhVKEWA@mail.gmail.com>
References: <1413071551-15372-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
 <543A36A0.8090300@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Daniel Kim <dekim-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <543A36A0.8090300-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-10-12 10:06 GMT+02:00 Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>:
> On 12-10-14 01:52, Rickard Strandqvist wrote:
>> Replacing strncpy with strlcpy to avoid strings that lacks null terminate.
>> And changed from using strncpy to strlcpy to simplify code.
>
> Looks good to me. Just two small process related remarks:
>
> - It is sufficient to prefix the patch with brcmfmac (skip net:...).
> - Send the patch to the wireless maintainer, ie. John Linville.

Hi

Sure, no problem.
Sending a new patch in a moment...

Kind regards
Rickard Strandqvist
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
