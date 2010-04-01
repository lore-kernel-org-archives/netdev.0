From: thomas yang <lampsu@gmail.com>
Subject: Re: [netfilter / iptables] question
Date: Fri, 2 Apr 2010 01:11:53 +0800
Message-ID: <n2if4f837ab1004011011gf3d82d3fzfd1423a812f98520@mail.gmail.com>
References: <v2if4f837ab1004010944yd08c37c5u23d6f2d07df7ccc6@mail.gmail.com>
	 <alpine.LSU.2.01.1004011857440.788@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f179.google.com ([209.85.222.179]:47147 "EHLO
	mail-pz0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754862Ab0DARLy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 13:11:54 -0400
Received: by pzk9 with SMTP id 9so1310676pzk.21
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 10:11:53 -0700 (PDT)
In-Reply-To: <alpine.LSU.2.01.1004011857440.788@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/4/2 Jan Engelhardt <jengelh@medozas.de>:
> On Thursday 2010-04-01 18:44, thomas yang wrote:
>
>>Hi,
>>
>>I want to copy/ clone a =A0sk_buff =A0*skb =A0to =A0*skb2 =A0on my Li=
nux router,
>> =A0then transmit both =A0skb2 =A0 and =A0skb =A0.
>>
>>How to do this with =A0 netfilter hook function =A0/ iptables =A0?
>>
> Wait for xt_TEE to be merged.
>

I want to route skb to 'path 1' , route the copied/cloned skb2 to
'path 2'    simultaneously,
if one of them lose , it will not be a problem.

What's the function of xt_TEE ?


--
Tom
