From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 23 Sep 2014 19:35:24 +0200
Message-ID: <5421AF5C.6000106@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <53FDF8EB.4050905@broadcom.com> <54169D4F.2090607@broadcom.com> <541EEF17.7020806@msgid.tls.msk.ru> <542145B1.4030202@msgid.tls.msk.ru> <54216BF1.3060500@broadcom.com> <20140923134419.GA19016@ubuntu-hedt> <54217AA5.2060803@broadcom.com> <542182BE.2000606@msgid.tls.msk.ru> <542183A6.4070207@msgid.tls.msk.ru> <20140923143124.GC19016@ubuntu-hedt> <54219984.2080601@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Seth Forshee <seth.forshee@canonical.com>,
	<brcm80211-dev-list@broadcom.com>,
	<linux-wireless@vger.kernel.org>, <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:24743 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932149AbaIWRf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 13:35:27 -0400
In-Reply-To: <54219984.2080601@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/14 18:02, Michael Tokarev wrote:
> 23.09.2014 18:31, Seth Forshee =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> On Tue, Sep 23, 2014 at 06:28:54PM +0400, Michael Tokarev wrote:
>>> 23.09.2014 18:25, Michael Tokarev wrote:
>>>> 23.09.2014 17:50, Arend van Spriel wrote:
>>>>> On 09/23/14 15:44, Seth Forshee wrote:
>>> []
>>>>>> It's been quite some time since I used them, but I think brcmsma=
c_tx is
>>>>>> quite noisy so you may only want to enable that if you already s=
uspect a
>>>>>> tx problem. I always find it useful to enable the mac80211 and
>>>>>> mac80211_msg events too when debugging wireless, and I often ena=
ble
>>>>>> cfg80211 events as well (none of these are especially verbose).
>>>
>>> mac80211_msg does not exist, it looks like.  fwiw.
>>
>> Did you check your kernel's config? You need to have
>> CONFIG_MAC80211_MESSAGE_TRACING enabled.
>
> Oh. Indeed.  While I enabled it, I recompiled only drivers/net/wirele=
ss,
> but not net/.  Rebuilt, another trace is here --
>
>   http://www.corpit.ru/mjt/tmp/brcmsmac-4313-trace-201409233.dat.gz
>
> Thanks,

Just to confirm. With this trace you also get a stall during wget?

Regards,
Arend

> /mjt
>
