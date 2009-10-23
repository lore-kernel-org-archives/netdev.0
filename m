From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Remove bond_dev from xmit_hash_policy call.
Date: Fri, 23 Oct 2009 18:05:46 +0200
Message-ID: <4AE1D45A.1010601@gmail.com>
References: <4AE1A37F.8010203@gmail.com> <20091023140924.GA24611@spaans.fox.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38600 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322AbZJWQFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 12:05:53 -0400
In-Reply-To: <20091023140924.GA24611@spaans.fox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jasper Spaans a =E9crit :
> Now that the bonding device is no longer used in determining the devi=
ce to
> which to send packets, it can be dropped from the argument list of th=
e various
> xmit_hash_policy calls.
>=20
> Signed-off-by: Jasper Spaans <spaans@fox-it.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Next step would be to use reciprocal divide :)
I'll take care of this eventually.
