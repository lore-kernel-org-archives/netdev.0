From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] [ETHTOOL]: Add support for large eeproms
Date: Thu, 24 Apr 2008 15:17:26 -0300
Message-ID: <4810CEB6.60707@linux.vnet.ibm.com>
References: <20080414180338.GA18335@google.com> <20080415.003153.30044057.davem@davemloft.net> <cc96a5040804151007q6008355cl2cc85242b81f3918@mail.gmail.com> <20080415.192330.29185957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: thockin@google.com, msb@google.com, netdev@vger.kernel.org,
	jeff@garzik.org, joe@perches.com, nil@google.com, matthew@wil.cx
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw1.br.ibm.com ([32.104.18.24]:52968 "EHLO igw1.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbYDXSRa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 14:17:30 -0400
Received: from mailhub3.br.ibm.com (mailhub3 [9.18.232.110])
	by igw1.br.ibm.com (Postfix) with ESMTP id 5208632C297
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 14:54:31 -0300 (BRST)
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.18.232.47])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3OIHR354300992
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 15:17:29 -0300
Received: from d24av02.br.ibm.com (loopback [127.0.0.1])
	by d24av02.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3OIHPMB028938
	for <netdev@vger.kernel.org>; Thu, 24 Apr 2008 15:17:26 -0300
In-Reply-To: <20080415.192330.29185957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Tim Hockin" <thockin@google.com>
> Date: Tue, 15 Apr 2008 10:07:21 -0700
>
>  =20
>> No device that I know of behaves that way.  It's certainly possible,
>> but I've never seen any sort of PROM device that has such a
>> requirement.
>>    =20
>
> Fair enough, let's apply the patch and see if anything explode :)
>  =20
I've just applied this patch, and I got something really strange now.  =
I=20
got the following message "Magic number 0x00000000 does not match 0x669=
955aa
" when I try to dump the eeprom from my tg3 card (BCM5780S rev. 03). I=20
suppose that somehow it isn't getting the correct NIC magic number.

Well, without the patch, I just got a "Cannnot allocate enough memory"=20
message when I rung the ethtool command, but if I pass the length=20
argument < 128k, then everything went ok.
Now, with the patch applied, I can't even dump  even using the length=20
parameter, since I hit the same Magic number error.

Note that I didn't run the kernel from your tree, I just backport this=20
patch to my current kernel 2.6.16, and tried it over a ppc machine. I'l=
l=20
run the kernel from your tree later and then post the result.

--
Breno Leit=C3=A3o
leitao@linux.vnet.ibm.com
