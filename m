From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: NAPI of many interfaces with just an interruption source
Date: Sat, 21 Feb 2009 21:12:51 +0800
Message-ID: <20090221131251.GA28821@gondor.apana.org.au>
References: <20090220105413.55e4f5f6@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gotzoncabanes@gmail.com, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34164 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752559AbZBUNNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 08:13:01 -0500
Content-Disposition: inline
In-Reply-To: <20090220105413.55e4f5f6@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote:
> On Fri, 20 Feb 2009 19:33:23 +0100
> Miguel =C1ngel =C1lvarez <gotzoncabanes@gmail.com> wrote:
>>=20
>> I have four interfaces that share the same interruption source (four
>> hdlc channels in ixp4xx that share the same rx queue... but I am
>> trying to do the question generic).
>
> Several other devices have this (like sky2).  Since NAPI needs
> to control irq, you need to have 1 NAPI instance per IRQ, so for
> these type of drivers there is 1 NAPI in hardware structure
> and multiple network devices.

Ben has just done exactly the same thing for his driver so he
can tell you all about it and how to use his generic function :)

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
