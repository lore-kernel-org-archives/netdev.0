From: Po-Yu Chuang <ratbert.chuang@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 21 Jan 2011 11:37:29 +0800
Message-ID: <AANLkTimSXZ_jk1PvAqzTWbr1b+GS6Y=m6zcSPaARp7dP@mail.gmail.com>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com> <AANLkTimFcEC0oXJGnJ7HQKLB9thfuWHeWSYSMCGR=hWJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, eric.dumazet@gmail.com, joe@perches.com,
	dilinger@queued.net, Po-Yu Chuang <ratbert@faraday-tech.com>
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTimFcEC0oXJGnJ7HQKLB9thfuWHeWSYSMCGR=hWJ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Micha=C5=82 ,

2011/1/21 Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com>:
> 2011/1/20 Po-Yu Chuang <ratbert.chuang@gmail.com>:
> [...]
>> +/******************************************************************=
************
>> + * internal functions (receive descriptor)
>> + ******************************************************************=
***********/
>> +static bool ftmac100_rxdes_first_segment(struct ftmac100_rxdes *rxd=
es)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 return le32_to_cpu(rxdes->rxdes0) & FTMAC100_=
RXDES0_FRS;
>> +}
>> +
>> +static bool ftmac100_rxdes_last_segment(struct ftmac100_rxdes *rxde=
s)
>> +{
>> + =C2=A0 =C2=A0 =C2=A0 return le32_to_cpu(rxdes->rxdes0) & FTMAC100_=
RXDES0_LRS;
>> +}
>> +
> [...]
>
> You can change these and similar functions to use:
>
> rxdes->rxdes0 & cpu_to_le32(FTMAC100_RXDES0_LRS)
>
> This will be subject to constant folding by compiler and produce
> better code for big-endian arches.

=46ixed. It looks much better now.
Thanks a lot.

best regards,
Po-Yu Chuang
