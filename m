From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next v2 01/10] headers, pppox: Add missing #include to
 <linux/if_pppox.h>
Date: Thu, 25 Aug 2011 05:40:48 +0100
Message-ID: <1314247249.27179.117.camel@deadeye>
References: <1314247131.27179.116.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-S+8qi45mLvsbkOwAugnQ"
Cc: netdev@vger.kernel.org, Michal Ostrowski <mostrows@earthlink.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37117 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751229Ab1HYEku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 00:40:50 -0400
In-Reply-To: <1314247131.27179.116.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-S+8qi45mLvsbkOwAugnQ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<linux/if_ppox.h> uses ETH_ALEN, defined in <linux/if_ether.h>.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 include/linux/if_pppox.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/if_pppox.h b/include/linux/if_pppox.h
index 397921b..60e5558 100644
--- a/include/linux/if_pppox.h
+++ b/include/linux/if_pppox.h
@@ -20,8 +20,8 @@
 #include <linux/types.h>
 #include <asm/byteorder.h>
=20
-#ifdef  __KERNEL__
 #include <linux/if_ether.h>
+#ifdef  __KERNEL__
 #include <linux/if.h>
 #include <linux/netdevice.h>
 #include <linux/ppp_channel.h>
--=20
1.7.5.4




--=-S+8qi45mLvsbkOwAugnQ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATlXSUOe/yOyVhhEJAQpVaRAAxyRU1SgwpkImYBngWxNMS8IPpFic8nrf
lJIQ1opHxO0H/9FrggWEWgfiTsUaNXi8Bs208v30TKjWvB3NHPHJ+uxEoKd/F5vy
skqXQt5VGHp6C8+9yQg5Ml8UwvvGe4WS63mJYBm84/f7+P/oWS8FLzRhtRH7BuFT
bSPG9vaiVEnEo8ZHZr7hiInNVPI7zYMkLT7OmESzDkDvwkKqHJ5LuVrC66VGnSKn
t65W6Q7iNVXw97vnklYUdF1XwrIggpbZpnPF3wEJHZK2JNpf8YRxghJTCYZmsdeK
4GS8C9gAEhtFcA4Rwv21jA1gaC1uy6srhaM40+7VrnWYHxse7G+9lBNDPGj0QnLh
0PVG1efQ0qyPFYfvonxuBjEaicTs9PrKIHSdzBmaGdf3/Ui9tZZUB6ayqKlIWryz
3kSWJBgIur+Zjt/OgrGp1ertImcMdhK8J3spKLvaGrDqZYTdsQLaEIu9c83DNR31
3oTVuN6980852wYlQh3VrVCgpt45QIre+tod2pWJVxCHjb3zx/C6JjT0bLXklpuS
IYbYDO+A2PASiZfPyTGESONv70LmT2R6KZoiQIOzKzpkJRo8wUQ9C1qALG3v0/Au
VWqPYKrxJfN/rxhPmz0GU4vUjtvvAq8+DooHTQMcR3rxI0czr+zMHNfoaHPMlAV7
ii8NssAX/NU=
=BHSJ
-----END PGP SIGNATURE-----

--=-S+8qi45mLvsbkOwAugnQ--
