From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] irda/qos.c: remove an unused function
Date: Fri, 29 Oct 2004 00:22:38 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028222238.GP3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; x-action=pgp-signed
Cc: irda-users@lists.sourceforge.net, davem@davemloft.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Dag Brattli <dagb@cs.uit.no>, Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

The patch below removes an unused function from net/irda/qos.c


diffstat output:
 net/irda/qos.c |   11 -----------
 1 files changed, 11 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

- --- linux-2.6.10-rc1-mm1-full/net/irda/qos.c.old	2004-10-28 23:51:59.000000000 +0200
+++ linux-2.6.10-rc1-mm1-full/net/irda/qos.c	2004-10-28 23:52:08.000000000 +0200
@@ -211,17 +211,6 @@
 	return index;
 }
 
- -static inline __u32 byte_value(__u8 byte, __u32 *array) 
- -{
- -	int index;
- -
- -	ASSERT(array != NULL, return -1;);
- -
- -	index = msb_index(byte);
- -
- -	return index_value(index, array);
- -}
- -
 /*
  * Function value_lower_bits (value, array)
  *
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.6 (GNU/Linux)

iD8DBQFBgXEumfzqmE8StAARAjtAAJwJtfTHsEupGVZWHqUG1L8ddNXQfACglX+r
SKDqqr8fPgPtMjBBkhIwkx8=
=zwcY
-----END PGP SIGNATURE-----
