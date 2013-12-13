From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCHv2 net-next 0/5] pktgen IPsec support
Date: Fri, 13 Dec 2013 16:56:24 +0800
Message-ID: <52AACBB8.4060009@windriver.com>
References: <1386323614-5077-1-git-send-email-fan.du@windriver.com>	<20131209.195854.223825767831436997.davem@davemloft.net>	<52A66C0D.4050409@windriver.com> <20131209.202321.2134510956668375662.davem@davemloft.net> <52A86BBE.1090408@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:47436 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751957Ab3LMI4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 03:56:47 -0500
In-Reply-To: <52A86BBE.1090408@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46WIW, I will follow Dave's suggestion not to touch your original
support at the first place no matter how below answer looks like.

On 2013=E5=B9=B412=E6=9C=8811=E6=97=A5 21:42, Jamal Hadi Salim wrote:
> On 12/09/13 20:23, David Miller wrote:
>
>> Maybe they didn't care about the checksum being correct in the
>> testbed they were using.
>
> Thats correct. The point is to exercise the crypto code.
> Please dont change this.

However exercising crypto engine on host running pktgen does *NOT* nece=
ssary
requiring bad IP checksum value and wrong total len value, because encr=
yption
has been done.

I'm confused here with your test rationale, and what's wrong to use
the right checksum/total length value? Please clear my puzzles.


Thanks
--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
