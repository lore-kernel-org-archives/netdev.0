From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: net-2.6.24 build broken (allyesconfig)
Date: Mon, 27 Aug 2007 14:52:59 +0200
Message-ID: <1188219179.7837.15.camel@johannes.berg>
References: <Pine.LNX.4.64.0708271522400.16245@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43013 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574AbXH0Mv5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2007 08:51:57 -0400
In-Reply-To: <Pine.LNX.4.64.0708271522400.16245@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-08-27 at 15:32 +0300, Ilpo J=C3=A4rvinen wrote:

> drivers/net/82596.c:1618:1: error: unterminated argument list invokin=
g=20
> macro "DEB"

> Hmm, I would guess that "[NET]: Introduce MAC_FMT/MAC_ARG" broken it,=
=20
> though didn't verify it.
>=20
> The fix is left as an exercise of the reader (i.e., the solution wasn=
't=20
> too obvious for me :-) )...

Yup, my fault, sorry about that.

=46rom: Johannes Berg <johannes@sipsolutions.net>
Subject: fix MAC_FMT/MAC_ARG in 82596.c

This fixes a typo in commit f98d4ca4986fec.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
 drivers/net/82596.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- netdev-2.6.orig/drivers/net/82596.c	2007-08-27 14:48:19.674646075 +=
0200
+++ netdev-2.6/drivers/net/82596.c	2007-08-27 14:48:21.674646075 +0200
@@ -1562,7 +1562,7 @@ static void set_multicast_list(struct ne
 			memcpy(cp, dmi->dmi_addr, 6);
 			if (i596_debug > 1)
 				DEB(DEB_MULTI,printk(KERN_INFO "%s: Adding address " MAC_FMT "\n",
-						dev->name, MAC_ARG(cp));
+						dev->name, MAC_ARG(cp)));
 		}
 		i596_add_cmd(dev, &cmd->cmd);
 	}


