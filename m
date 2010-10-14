From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: dont use netdev_alloc_skb()
Date: Thu, 14 Oct 2010 20:20:20 +0200
Message-ID: <1287080420.2712.102.camel@edumazet-laptop>
References: <AANLkTi=NvnPov_=KQJz2uXt1R-ep4oahDF0J=3HwhGzG@mail.gmail.com>
	 <1286860560.30423.186.camel@edumazet-laptop>
	 <8628FE4E7912BF47A96AE7DD7BAC0AADDDEE4282DD@SJEXCHCCR02.corp.ad.broadcom.com>
	 <20101014.103914.193713537.davem@davemloft.net>
	 <1287080255.22035.2.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41472 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755862Ab0JNSU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 14:20:29 -0400
Received: by wyb28 with SMTP id 28so2404693wyb.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 11:20:28 -0700 (PDT)
In-Reply-To: <1287080255.22035.2.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 octobre 2010 =C3=A0 20:17 +0200, Eilon Greenstein a =C3=A9c=
rit :
> On Thu, 2010-10-14 at 10:39 -0700, David Miller wrote:
> > From: "Vladislav Zolotarov" <vladz@broadcom.com>
> > Date: Tue, 12 Oct 2010 02:12:41 -0700
> >=20
> > > Dave, if it can wait till tomorrow, I'd like to ask u to wait for=
 Eilon's
> > > final ACK.
> >=20
> > Ok, but it is two days later now :-)
> >=20
>=20
> I was under the impression that the current path is to revert
> b30973f877fea1a3fb84e05599890fcc082a88e5 instead of the original thre=
ad.
> Eric - do you still want to apply the original patch from this thread=
?

No, this patch is not needed, if the generic one is considered.

We might change copybreak stuff, but not all skb allocations in bnx2x

Thanks


