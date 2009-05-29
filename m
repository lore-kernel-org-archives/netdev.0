From: Piotrek D <regis44@gmail.com>
Subject: Re: changing the qdisc class speed rate
Date: Fri, 29 May 2009 21:03:50 +0200
Message-ID: <620d582f0905291203n69bce7bkd2c06d48d27f5003@mail.gmail.com>
References: <50214222-779D-4C49-9151-C725C8F470D5@gmail.com>
	 <20090527222158.42f71e28@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f168.google.com ([209.85.220.168]:57176 "EHLO
	mail-fx0-f168.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753784AbZE2TDt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 15:03:49 -0400
Received: by fxm12 with SMTP id 12so4585854fxm.37
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 12:03:50 -0700 (PDT)
In-Reply-To: <20090527222158.42f71e28@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is what I have done, the  cl->rate->rate.rate refers to the __u32
rate in htb_class -> qdisc_rate_table -> tc_ratespec .
What else should I modify to make this work ?

Piotrek


W dniu 28 maja 2009 07:21 u=BFytkownik Stephen Hemminger
<shemminger@vyatta.com> napisa=B3:
> On Thu, 28 May 2009 07:12:33 +0200
> Piotr Duszy=F1ski <regis44@gmail.com> wrote:
>
>> Hi everyone,
>>
>> I am trying to change the rate parameter of HTB class by using this
>> code from within one of my functions :
>>
>> =A0 =A0struct htb_class *cl;
>> =A0 =A0cl=3Dhtb_find(number,q);
>>
>> =A0 =A0cl->rate->rate.rate =3D NEW_RATE_VALUE;
>>
>> =A0 =A0TC shows the correct values, but the traffic rate doesn't cha=
nge a
>> bit.
>> =A0 =A0Does anyone have any idea what am I doing wrong ? Maybe there=
 would
>> be a faster way by sending a netlink =A0message ?
>>
>> Piotrek
>
> HTB uses a rate table, so if you want the rate to change, you will ne=
ed to change the
> table as well.
>
