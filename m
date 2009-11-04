From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 4 Nov 2009 17:19:15 +0900
Message-ID: <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>
	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
	 <4AF10B1D.4050604@gmail.com> <4AF110CE.8070701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:33390 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbZKDITK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 03:19:10 -0500
Received: by vws30 with SMTP id 30so1869718vws.33
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 00:19:15 -0800 (PST)
In-Reply-To: <4AF110CE.8070701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Wed, Nov 4, 2009 at 2:27 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Eric Dumazet a =E9crit :
>>
>> Hmm, do you know part of the error comes from the user tool itself ?
>>
>> If you check iperf results at sender and receiver you'll see differe=
nt
>> values, sender lies a bit.
>>
>> Tried here on a Gbit link (I dont have 10Gbe yet)
>>
>> $ ./iperf.bench.sh
>> .100 104
>> .200 206
>> .300 307
>> .400 413
>> .500 515
>> .600 610
>> .700 715
>> .800 822
>> .900 913
>> 1.000 945
>>
> (that was with standard 1500 MTU)
>
> Now, with 9000 MTU and 50 seconds samples (instead of 5 s) I get :
>
> $ ./iperf.bench.sh
> .100 101
> .200 200
> .300 301
> .400 401
> .500 500
> .600 601
> .700 700
> .800 803
> .900 903
> 1.000 991
>
> Not too bad :)
>

I tried iperf with 60 seconds samples. I got the almost same result.

Here is the result:
      sender	receiver
1.000 1.00	1.00
2.000 2.01	2.01
3.000 3.03	3.02
4.000 4.07	4.07
5.000 5.05	5.05
6.000 6.16	6.16
7.000 7.22	7.22
8.000 8.15	8.15
9.000 9.23	9.23
9.900 9.69	9.69

Best regards,
Ryousei Takano
