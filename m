From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTGMAC100 Gigabit Ethernet driver
Date: Mon, 21 Mar 2011 15:54:41 +0800
Message-ID: <AANLkTinibrF_bJBbYwCSnGv1iD_9Dn7uBn2cqgcTrKHi@mail.gmail.com>
References: <1299744517-1896-1-git-send-email-ratbert.chuang@gmail.com>
 <1300355238-1619-1-git-send-email-ratbert.chuang@gmail.com>
 <1300357457.3133.92.camel@edumazet-laptop> <AANLkTino6LzGTZF4fNSkV9pbAfnmAc8wJjk0L8HfHDiJ@mail.gmail.com>
 <1300361405.3133.175.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48928 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab1CUHzC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 03:55:02 -0400
In-Reply-To: <1300361405.3133.175.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Mar 17, 2011 at 7:30 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le jeudi 17 mars 2011 =C3=A0 18:56 +0800, Po-Yu Chuang a =C3=A9crit :
>> On Thu, Mar 17, 2011 at 6:24 PM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
>> > Le jeudi 17 mars 2011 =C3=A0 17:47 +0800, Po-Yu Chuang a =C3=A9cri=
t :
>> >> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>> >>
>> >> FTGMAC100 Ethernet Media Access Controller supports 10/100/1000 M=
bps
>> >> and MII/GMII. =C2=A0This driver has been working on some ARM/NDS3=
2 SoC's
>> >> including Faraday A369 and Andes AG102.
>> >>
>> >> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>
>> >> ---
>> >
>> > Did you tried GRO support ?
>>
>> No, I don't understand how to do that yet. Let me do some study firs=
t.
>> I'd really appreciate it if you could provide me some pointers about=
 GRO. :-)
>> Is there any document about it?
>
> Should be easy and might help performance too.
>
> Take a look at commit :
>
> 2edae08e5b75269855fef3c74fe4292c066e7c33 (r8169: add gro support)

It seems to work fine so far at least the driver is not broken, but I d=
id not
see much difference in performance though. How do I know if GRO is
working indeed?

Best regards,
Po-Yu Chuang
