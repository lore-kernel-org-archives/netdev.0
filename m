From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [0/7] [PPP]: Fix shared/cloned/non-linear skb bugs (was: malformed captured packets)
Date: Wed, 19 Sep 2007 19:51:48 +0800
Message-ID: <20070919115148.GB19866@gondor.apana.org.au>
References: <200708281811.34074.toralf.foerster@gmx.de> <46D69323.3070503@katalix.com> <20070831090625.GA28175@gondor.apana.org.au> <200709112012.53165.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Paul Mackerras <paulus@samba.org>,
	James Chapman <jchapman@katalix.com>
To: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3253 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754543AbXISLvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 07:51:53 -0400
Content-Disposition: inline
In-Reply-To: <200709112012.53165.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 11, 2007 at 08:12:50PM +0200, Toralf F=F6rster wrote:
>=20
> I'm wondering why some UDP packets of the MS messenger protocol (with=
 the usual
> text like "please click at www.we-destroy-your-computer.com") always =
have wrong
> check sums regardless whether sniffed at ppp0 or eth0 interface.

Maybe your wireshark is broken? I've tried wireshark and tcpdump
here and the sums look fine.

> and I'm wondering why it is still possible to capture such packets at=
 eth0.

tcpdump happens before the packet goes into the IP stack which
is whare iptables lives.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
