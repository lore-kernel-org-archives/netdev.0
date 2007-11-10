From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: UDP-Lite and /proc/net/snmp
Date: Sat, 10 Nov 2007 22:33:25 +0800
Message-ID: <20071110143325.GA6888@gondor.apana.org.au>
References: <20071110131428.GA6447@gondor.apana.org.au> <20071110.223243.114494952.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2855 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751385AbXKJOdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 09:33:32 -0500
Content-Disposition: inline
In-Reply-To: <20071110.223243.114494952.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Nov 10, 2007 at 10:32:43PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>
> Hmm?  netstat 1.42 (net-tools 1.60) seems fine.
> Which netstat are you using?

The one from Debian etch:

$ netstat -V
net-tools 1.60
netstat 1.42 (2001-04-15)
=46red Baumgarten, Alan Cox, Bernd Eckenfels, Phil Blundell, Tuan Hoang=
 and others
+NEW_ADDRT +RTF_IRTT +RTF_REJECT +FW_MASQUERADE +I18N
AF: (inet) +UNIX +INET +INET6 +IPX +AX25 +NETROM +X25 +ATALK +ECONET +R=
OSE
HW:  +ETHER +ARC +SLIP +PPP +TUNNEL +TR +AX25 +NETROM +X25 +FR +ROSE +A=
SH +SIT +FDDI +HIPPI +HDLC/LAPB +EUI64
$

BTW, netstat only breaks if you run it with -s as otherwise
it doesn't look at /proc/net/snmp.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
