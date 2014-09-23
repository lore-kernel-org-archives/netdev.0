From: Michael Tokarev <mjt-XAri/EZa3C4vJsYlp49lxw@public.gmane.org>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 23 Sep 2014 20:02:12 +0400
Message-ID: <54219984.2080601@msgid.tls.msk.ru>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru> <542183A6.4070207@msgid.tls.msk.ru> <20140923143124.GC19016@ubuntu-hedt>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140923143124.GC19016@ubuntu-hedt>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

23.09.2014 18:31, Seth Forshee =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Tue, Sep 23, 2014 at 06:28:54PM +0400, Michael Tokarev wrote:
>> 23.09.2014 18:25, Michael Tokarev wrote:
>>> 23.09.2014 17:50, Arend van Spriel wrote:
>>>> On 09/23/14 15:44, Seth Forshee wrote:
>> []
>>>>> It's been quite some time since I used them, but I think brcmsmac=
_tx is
>>>>> quite noisy so you may only want to enable that if you already su=
spect a
>>>>> tx problem. I always find it useful to enable the mac80211 and
>>>>> mac80211_msg events too when debugging wireless, and I often enab=
le
>>>>> cfg80211 events as well (none of these are especially verbose).
>>
>> mac80211_msg does not exist, it looks like.  fwiw.
>=20
> Did you check your kernel's config? You need to have
> CONFIG_MAC80211_MESSAGE_TRACING enabled.

Oh. Indeed.  While I enabled it, I recompiled only drivers/net/wireless=
,
but not net/.  Rebuilt, another trace is here --

 http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-201409233.dat.gz

Thanks,

/mjt

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
