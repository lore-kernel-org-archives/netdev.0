From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC ipsec-next] xfrm: make sha256 icv truncation length RFC-compliant
Date: Thu, 22 May 2014 18:03:36 +0200
Message-ID: <537E1FD8.8030504@6wind.com>
References: <1400771437-14096-1-git-send-email-horia.geanta@freescale.com> <1400771437-14096-2-git-send-email-horia.geanta@freescale.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lei Xu <Lei.Xu@freescale.com>,
	Sandeep Malik <Sandeep.Malik@freescale.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Horia Geanta <horia.geanta@freescale.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:41866 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaEVQDk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 12:03:40 -0400
Received: by mail-wg0-f41.google.com with SMTP id z12so3620825wgg.12
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 09:03:39 -0700 (PDT)
In-Reply-To: <1400771437-14096-2-git-send-email-horia.geanta@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/05/2014 17:10, Horia Geanta a =C3=A9crit :
> From: Lei Xu <Lei.Xu@freescale.com>
>
> Currently the sha256 icv truncation length is set to 96bit
> while the length is defined as 128bit in RFC4868.
> This may result in somer errors when working with other IPsec devices
> with the standard truncation length.
> Thus, change the sha256 truncation length from 96bit to 128bit.
The patch was already proposed, but it was kept as-is for userspace
compatibility.

See: https://lkml.org/lkml/2012/3/7/431

Regards,
Nicolas
