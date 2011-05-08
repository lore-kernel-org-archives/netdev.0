From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Sun, 08 May 2011 16:10:12 -0700 (PDT)
Message-ID: <20110508.161012.258121848.davem@davemloft.net>
References: <1304791360.1738.6.camel@Joe-Laptop>
	<BANLkTimKs39m_htMFEygR+3Bfu7Butc-zQ@mail.gmail.com>
	<BANLkTik_gMCHYp4sOnzzR1Gs=bn2pkpjfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mfmooney@gmail.com, joe@perches.com, aquini@linux.com,
	kernel-janitors@vger.kernel.org, fubar@us.ibm.com,
	andy@greyhouse.net, shemminger@vyatta.com, netdev@vger.kernel.org,
	nikai@nikai.net
To: hlovdal@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754550Ab1EHXKo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 19:10:44 -0400
In-Reply-To: <BANLkTik_gMCHYp4sOnzzR1Gs=bn2pkpjfQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: H=E5kon L=F8vdal <hlovdal@gmail.com>
Date: Mon, 9 May 2011 01:08:44 +0200

> On 7 May 2011 21:35, matt mooney <mfmooney@gmail.com> wrote:
>> But isn't the preferred style to have a single exit point?
>=20
> This is generally considered to be a bad advice, see
> http://stackoverflow.com/questions/1701686/why-should-methods-have-a-=
single-entry-and-exit-points/1701721#1701721
> for instance.

That article totally ignores the issue of locking and how hard it is
to get right without single exit points, and how unlocking in
multiple spots bloats up the code.

Definitely don't take that article's advice when working on the
kernel.
