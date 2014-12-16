From: Arend van Spriel <arend@broadcom.com>
Subject: Re: BCM4313 & brcmsmac & 3.12: only semi-working?
Date: Tue, 16 Dec 2014 17:51:10 +0100
Message-ID: <549062FE.2000808@broadcom.com>
References: <53FDACD1.8090805@msgid.tls.msk.ru> <54363ED0.605@broadcom.com> <CACna6rw3XgdJz0uKkAuas8RTzozTdFp2mgF5g1uo7LHJVSMt4g@mail.gmail.com> <3543341.FmUQFH9nrl@eisbaer> <546C5D1F.108@msgid.tls.msk.ru> <546CD94D.9060509@broadcom.com> <546CF66A.3000207@msgid.tls.msk.ru> <546D04EE.1030200@msgid.tls.msk.ru> <5471AC29.6040009@broadcom.com> <5475A2DC.80502@msgid.tls.msk.ru> <547B07CF.90501@broadcom.com> <547E31BD.8090302@msgid.tls.msk.ru> <547F0575.7010104@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Maximilian Engelhardt <maxi@daemonizer.de>,
	=?UTF-8?B?UmFmYcWCIE1pxYJl?= =?UTF-8?B?Y2tp?= <zajec5@gmail.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	brcm80211 development <brcm80211-dev-list@broadcom.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:4796 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbaLPQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 11:51:13 -0500
In-Reply-To: <547F0575.7010104@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/14 13:43, Arend van Spriel wrote:
> On 12/02/14 22:40, Michael Tokarev wrote:
>> 30.11.2014 15:04, Arend van Spriel wrote:
>>
>>> Thanks. Did not find what I was looking for, but I started working on
>>> integrating btcoex related functionality. The attached patch will print
>>> some info so I can focus on the required functionality for your device.
>>> It is based on 3.18-rc5.
>>
>> With this patch applied against 3.18-rc5, the machine instantly reboots
>> once brcmsmac module is loaded. I'm still debugging this.

Hmm. The function brcms_btc_ecicoex_enab() is calling itself. Please 
remove that call as it causes endless recursion and eventually reboot.

Regards,
Arend

> Argh. Probably the register access I added end up in limbo land or some
> other stupid mistake. I will double check my patch.
>
> Regards,
> Arend
>
>> Thanks,
>>
>> /mjt
>
