From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH v3] rps: optimize rps_get_cpu()
Date: Sun, 25 Apr 2010 14:48:49 +0800
Message-ID: <z2h412e6f7f1004242348ibd5f96a2i7cd0557c37bb0921@mail.gmail.com>
References: <1272122227-13070-1-git-send-email-xiaosuo@gmail.com>
	<20100424.225128.52181685.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:37650 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038Ab0DYGtL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Apr 2010 02:49:11 -0400
Received: by iwn8 with SMTP id 8so4025995iwn.16
        for <netdev@vger.kernel.org>; Sat, 24 Apr 2010 23:49:09 -0700 (PDT)
In-Reply-To: <20100424.225128.52181685.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 25, 2010 at 1:51 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Sat, 24 Apr 2010 23:17:07 +0800
>
>> optimize rps_get_cpu().
>>
>> don't initialize ports when we can get the ports. one memory access =
for ports
>> than two.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Applied, thanks.
>
> We can load both addresses in one go on 64-bit btw.
>

Are they always aligned to 64-bit boundary? I don't think so.



--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
