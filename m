From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH REPOST net-next-2.6 3/4] bonding: Fix useless test: int
 > INT_MAX
Date: Fri, 28 Aug 2009 15:49:11 -0700 (PDT)
Message-ID: <20090828.154911.197007102.davem@davemloft.net>
References: <1251497115-16234-2-git-send-email-fubar@us.ibm.com>
	<1251497115-16234-3-git-send-email-fubar@us.ibm.com>
	<1251497115-16234-4-git-send-email-fubar@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, nicolas.2p.debian@free.fr
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750790AbZH1Ws6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Aug 2009 18:48:58 -0400
In-Reply-To: <1251497115-16234-4-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jay Vosburgh <fubar@us.ibm.com>
Date: Fri, 28 Aug 2009 15:05:14 -0700

> From: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
>=20
> max_bonds is of type int and cannot be greater than INT_MAX.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

It seems you use two different encodings here for Nicolas's
last name, and thus the two-dotted 'u' comes out corrupted
in the From: field.

This causes patchwork to not be able to parse the patch
and thus put it properly into the queue.  So all that's
in there are patches #1, #2 and #4.

