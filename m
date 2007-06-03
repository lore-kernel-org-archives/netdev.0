From: Mick McCreath <mick_mccreath@au.securecomputing.com>
Subject: Re: raw sockets ignore IP_HDRINCL data
Date: Mon, 04 Jun 2007 08:52:07 +1000
Message-ID: <1180911127.5956.64.camel@localhost>
References: <E1HuRS1-0002aE-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:42304 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751720AbXFCWwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jun 2007 18:52:16 -0400
In-Reply-To: <E1HuRS1-0002aE-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbet,

Thanks for the feedback.

On Sat, 2007-06-02 at 21:07 +1000, Herbert Xu wrote:
> Mick McCreath <mick_mccreath@au.securecomputing.com> wrote:
> >=20
> > When I run traceroute -i eth1 5.4.3.2, the UDP packets are routed o=
ut
> > eth2.
> >=20
> > Has anybody seen this behaviour with traceroute??
>=20
> Well the version of traceroute here actually does a BINDTODEVICE so i=
t
> will go out of the right interface.  It also binds the socket so that
> it gets the right source address.
>=20

Which traceroute are you using??

I am using version 1.4a12 by Van Jacobson downloaded from Lawrence
Berkeley Labs.

In this one, it only binds if IP_HDRINCL is not defined (in a #ifndef).

> I can see your point of view that it would be nice if the kernel read
> the IP headers in making its routing decision.  However, the current
> behaviour has been there forever and it's unclear what we might break
> by changing it.

I sort of thought that might be the case :-)

Cheers,

--=20
--
Mick McCreath
Sr Engineer

Secure Computing=C2=AE
your trusted source for enterprise security=E2=84=A2
www.securecomputing.com
NASDAQ: SCUR

61 7 3435 2803 (Direct Phone)
mick_mccreath@securecomputing.com

Secure Computing Corporation
825 Stanley Street
Woolloongabba
Queensland 4102
Australia

The information contained in this email message may be privileged,
confidential and protected from disclosure. If you are not the intended
recipient, any review, dissemination, distribution or copying is
strictly prohibited. If you have received this email message in error,
please notify the sender by reply email and delete the message and any
attachments.

