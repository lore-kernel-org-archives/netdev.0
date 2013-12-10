From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Tue, 10 Dec 2013 10:02:36 +0800
Message-ID: <52A6763C.4050101@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>	<20131209.195854.223825767831436997.davem@davemloft.net>	<52A66C0D.4050409@windriver.com> <20131209.202321.2134510956668375662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59525 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab3LJCCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:02:52 -0500
In-Reply-To: <20131209.202321.2134510956668375662.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8810=E6=97=A5 09:23, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Tue, 10 Dec 2013 09:19:09 +0800
>
>> How it could be usable first and then useful for someone before my f=
ix
>> 9e921193884dd85b4cd68aa18598d8c2f9ad85b9
>> ({pktgen, xfrm} Correct xfrm state lock usage when transforming)???

slip of pen here, should be commit:
3868204d6b89ea373a273e760609cb08020beb1a
("{pktgen, xfrm} Update IPv4 header total len and checksum after transf=
ormation")

>> Do you really know what this fix does?
>
> Maybe they didn't care about the checksum being correct in the
> testbed they were using.

Can I just reply to custom "Yes, wrong checksum value and non-decrypted=
 packet
is not big deal when your peer host receiving them"?

> I know Jamal used it when he added the feature.

Please re-consider your approach for this patch set, really.

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
