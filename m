From: David Miller <davem@davemloft.net>
Subject: Re: Bug in netem reordering
Date: Thu, 05 Jan 2012 13:28:44 -0500 (EST)
Message-ID: <20120105.132844.667708412405670292.davem@davemloft.net>
References: <CAGK4HS8YBBwPtPpQhi8gas=RBE6wao6KZ1dwbwo2rxn4qXggCQ@mail.gmail.com>
	<1325734526-13428-1-git-send-email-hagen@jauu.net>
	<1325741656.2634.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hagen@jauu.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758015Ab2AES2x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 13:28:53 -0500
In-Reply-To: <1325741656.2634.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jan 2012 06:34:16 +0100

> Le jeudi 05 janvier 2012 =E0 04:35 +0100, Hagen Paul Pfeifer a =E9cri=
t :
>> Not now, but it looks you are correct. q->qdisc is NULL until anothe=
r
>> additional qdisc is attached (beside tfifo). See 50612537e9ab2969312=
=2E
>> The following patch should work.
>>=20
>> From: Hagen Paul Pfeifer <hagen@jauu.net>
>>=20
>> netem: catch NULL pointer by updating the real qdisc statistic
>>=20
>> Reported-by: Vijay Subramanian <subramanian.vijay@gmail.com>
>> Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
>> ---
>=20
> Thanks for this fix !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
