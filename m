From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Thu, 5 Nov 2009 19:15:30 +0900
Message-ID: <b30d1c3b0911050215q5f1065b2sf7bc82ff6709e810@mail.gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
	 <4AF10B1D.4050604@gmail.com> <4AF110CE.8070701@gmail.com>
	 <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>
	 <4AF1660E.1080401@gmail.com>
	 <b30d1c3b0911040831y7aeac556raf7cae9106b5bc7b@mail.gmail.com>
	 <4AF1B3CB.1050008@gmail.com>
	 <b30d1c3b0911042308n616bc360v7b96b6543029f232@mail.gmail.com>
	 <4AF27A48.4090001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:44998 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751081AbZKEKPZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 05:15:25 -0500
Received: by vws30 with SMTP id 30so2237593vws.33
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2009 02:15:30 -0800 (PST)
In-Reply-To: <4AF27A48.4090001@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Nov 5, 2009 at 4:10 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Ryousei Takano a =E9crit :
>> In my experiment, it is not very big problem. =A0I do not send short=
 packets.
>> I got the almost same result in the both cases "mtu 64000" and "mtu
>> 40000 quantum 60000".
>>
>> Anyway, setting larger mtu size than the physical mtu does not quiet=
 make sense.
>>
>
> tc class mtu is a hint given to stack, about average packet size, ie =
not
> related to physical MTU (because of TSO)
>
> You could use same mtu, but disable tso on device
>
I got it.
Thanks for your explanation.

Best regards,
Ryousei
