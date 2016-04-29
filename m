From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net] ipv6/ila: fix nlsize calculation for lwtunnel
Date: Fri, 29 Apr 2016 15:35:33 +0200
Message-ID: <57236325.2000304@6wind.com>
References: <1461340682-31568-1-git-send-email-nicolas.dichtel@6wind.com>
 <20160427.152053.2243888701043810040.davem@davemloft.net>
 <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36995 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbcD2Nfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 09:35:36 -0400
Received: by mail-wm0-f45.google.com with SMTP id a17so36854028wme.0
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 06:35:36 -0700 (PDT)
In-Reply-To: <CALx6S36jkPqx5U+B9akRYZ+xiRhozk_AdOmKBEr4N9mhwTKQMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/04/2016 18:07, Tom Herbert a =C3=A9crit :
> On Wed, Apr 27, 2016 at 12:20 PM, David Miller <davem@davemloft.net> =
wrote:
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Fri, 22 Apr 2016 17:58:02 +0200
>>
>>> The handler 'ila_fill_encap_info' adds one attribute: ILA_ATTR_LOCA=
TOR.
>>>
>>> Fixes: 65d7ab8de582 ("net: Identifier Locator Addressing module")
>>> CC: Tom Herbert <tom@herbertland.com>
>>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>>> ---
>>>
>>> Tom, when I read the comment, I feel I'm misssing something, but wh=
at?
>>
>> Tom, seriously, please look at this.
>>
> Yes, it is an issue. Need to do add size for ILA_ATTR_LOCATOR and
> ILA_ATTR_CSUM_MODE. Also not we made ILA_ATTR_CSUM_MODE u64 in fill
> encap info. I will send a path shortly.
David, I saw that you didn't apply this patch. Note that Tom's patch is
for net-next while this one is for net.
I think that both patches are needed (and they will conflict after the =
next merge).


Regards,
Nicolas
