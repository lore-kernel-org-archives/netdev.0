From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix broken register writes
Date: Sun, 28 Mar 2010 23:28:58 +0200
Message-ID: <20100328212858.GA4220@electric-eye.fr.zoreil.com>
References: <4BAE6C92.2060801@iki.fi>
 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
 <1269732054.8653.155.camel@localhost>
 <20100327.163005.28815553.davem@davemloft.net>
 <20100328003143.GA8501@electric-eye.fr.zoreil.com>
 <1269737245.8653.162.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, timo.teras@iki.fi,
	ivecera@redhat.com, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:37410 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755214Ab0C1V3t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 17:29:49 -0400
Content-Disposition: inline
In-Reply-To: <1269737245.8653.162.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <ben@decadent.org.uk> :
[...]
> Thanks Fran=E7ois.  Which hardware have you tested this on so far ?

10ec:8169 (rev 10) / RTL8169sb/8110sb / XID 10000000

Timo's is a 10ec:8167 / RTL8169sc/8110sc / XID 18000000. He only tested
the MAC[04] part.

Old stuff.

> I was hesitant to make changes because of the huge number of variants=
=2E

Things will be amended if they break and reverted if they get out of
control.

--=20
Ueimor
