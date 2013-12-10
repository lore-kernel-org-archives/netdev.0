From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Tue, 10 Dec 2013 10:27:55 +0800
Message-ID: <52A67C2B.2030508@windriver.com>
References: <52A66C0D.4050409@windriver.com>	<20131209.202321.2134510956668375662.davem@davemloft.net>	<52A6763C.4050101@windriver.com> <20131209.210916.1684103670392129860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <steffen.klassert@secunet.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63196 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3LJC2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:28:12 -0500
In-Reply-To: <20131209.210916.1684103670392129860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B412=E6=9C=8810=E6=97=A5 10:09, David Miller wrote:
> From: Fan Du<fan.du@windriver.com>
> Date: Tue, 10 Dec 2013 10:02:36 +0800
>
>> Can I just reply to custom "Yes, wrong checksum value and
>> non-decrypted packet
>> is not big deal when your peer host receiving them"?
>
> It's a packet spamming tool, take that into consideration.
> Regardless of what you may think, it is simply the case that you can'=
t
> just remove something because you perceive it as not useful to anyone=
=2E
>
> This goes doubly for something exposed to users for a decade.
>
> Please change your patch series to retain the feature.

I will restore "wrong checksum/len packet" behavior as a default behavi=
or,
As a matter of fact this has nothing to do with Patch1/5 which removes =
codes.
And then making enhanced feature as optional for user who expects good =
format packet

Is this fine for you, finally?


> Thanks.
>
>

--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
