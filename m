From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Wed, 21 Nov 2007 19:17:40 -0500
Message-ID: <4744CAA4.50102@garzik.org>
References: <20071121124532.GA17263@havoc.gtf.org> <20071121.222051.94402865.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47594 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752252AbXKVARy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 19:17:54 -0500
In-Reply-To: <20071121.222051.94402865.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20071121124532.GA17263@havoc.gtf.org> (at Wed, 21 Nov 200=
7 07:45:32 -0500), Jeff Garzik <jeff@garzik.org> says:
>=20
>> SO_NO_CHECK support for IPv6 appeared to be missing. This is present=
ed,
>> based on a reading of net/ipv4/udp.c.
>=20
> Disagree. UDP checksum is mandatory in IPv6.

Ah, you mean that I need to turn off UDP checksum on receive end as wel=
l=20
in IPv6...  true.

=46or those interested, I am dealing with a UDP app that already does v=
ery=20
strong checksumming and encryption, so additional software checksumming=
=20
at the lower layers is quite simply a waste of CPU cycles.  Hardware=20
checksumming is fine, as long as its "free."

	Jeff



