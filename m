From: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Sun, 21 Dec 2014 11:12:40 +0100
Message-ID: <54969D18.3060000@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer> <546C5D1F.108@msgid.tls.msk.ru> <546CD94D.9060509@broadcom.com> <546CF66A.3000207@msgid.tls.msk.ru> <546D04EE.1030200@msgid.tls.msk.ru> <5471AC29.6040009@broadcom.com> <5475A2DC.80502@msgid.tls.msk.ru> <547B07CF.90501@broadcom.com> <547E31BD.8090302@msgid.tls.msk.ru> <547F0575.7010104@broadcom.com> <549062FE.2000808@broadcom.com> <549699D9.2060106@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	brcm80211 development <brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <549699D9.2060106-Gdu+ltImwkhes2APU0mLOQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 12/21/14 10:58, Michael Tokarev wrote:
> 16.12.2014 19:51, Arend van Spriel wrote:
>
>> Hmm. The function brcms_btc_ecicoex_enab() is calling itself. Please remove that call as it causes endless recursion and eventually reboot.
>
> Ok, that was easy.  Now it loads, but wifi link still
> does not work, stalling as before.  What we're looking
> at now?

The patch is just to provide me with extra bt-coex related information 
in the kernel log. So if you can provide that to me I have to info 
needed to look in the proprietary code base to determine what is missing.

Regards,
Arend

> (To have a common base, I applied this bt-coex patch to
> 3.18.0 kernel.  I can also apply the previously mentioned
> debugging/stats patch too).
>
> Thanks,
>
> /mjt

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
