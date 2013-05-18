From: =?ISO-8859-1?Q?Holger_Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Re: [PATCH v2 net 1/1] r8169: fix offloaded tx checksum for small
 packets.
Date: Sat, 18 May 2013 16:42:52 +0200
Message-ID: <5197936C.6090607@googlemail.com>
References: <20130518112446.GA21268@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Ben Hutchings <ben@decadent.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-02-ewr.mailhop.org ([204.13.248.72]:33720 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751989Ab3EROm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 May 2013 10:42:58 -0400
In-Reply-To: <20130518112446.GA21268@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 18.05.2013 13:24, Francois Romieu wrote:
> 8168evl offloaded checksums are wrong since commit
> e5195c1f31f399289347e043d6abf3ffa80f0005 ("r8169: fix 8168evl frame p=
adding.")
> pads small packets to 60 bytes (without ethernet checksum). Typical s=
ymptoms
> appear as UDP checksums which are wrong by the count of added bytes.
>=20
> It isn't worth compensating. Let the driver checksum.
>=20
> Due to the skb length changes, TSO code is moved before the Tx descri=
ptor gets
> written.
>=20
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Tested again, still working for me.

Tested-by: Holger Hoffst=E4tte <holger.hoffstaette@googlemail.com>

-h
