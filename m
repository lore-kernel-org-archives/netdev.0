From: Piotrek D <regis44@gmail.com>
Subject: Re: HTB class parameter change
Date: Fri, 29 May 2009 07:41:34 +0200
Message-ID: <620d582f0905282241n1b1dd47anb27c6a377161e751@mail.gmail.com>
References: <620d582f0905281347w5aa96a85na5339aed87db5464@mail.gmail.com>
	 <4A1EFA1B.2020002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:47120 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637AbZE2Fle convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 01:41:34 -0400
Received: by bwz22 with SMTP id 22so5899122bwz.37
        for <netdev@vger.kernel.org>; Thu, 28 May 2009 22:41:35 -0700 (PDT)
In-Reply-To: <4A1EFA1B.2020002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for double posting. I haven't noticed the previous reply.

Piotrek

2009/5/28 Eric Dumazet <eric.dumazet@gmail.com>:
> Piotrek D a =E9crit :
>> HI,
>>
>> I am trying to change the rate parameter of HTB class by using this
>> code from within one of my functions :
>>
>> =A0struct htb_class *cl;
>> =A0cl=3Dhtb_find(number,q);
>>
>> =A0cl->rate->rate.rate =3D NEW_RATE_VALUE;
>>
>> =A0TC shows the correct values, but the traffic rate doesn't change =
a bit.
>> =A0Does anyboyd have any idea what am I doing wrong ? Maybe there wo=
uld
>> be a faster way by sending a netlink =A0message ?
>>
>> Piotrek
>
>
> You already asked this 15 hours ago and Stephen replied :
>
> "HTB uses a rate table, so if you want the rate to change, you will n=
eed to change the
> table as well."
>
> Did you miss this answer ?
>
>
