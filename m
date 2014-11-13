From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: lib: rhashtable - Remove weird non-ASCII characters from comments
Date: Thu, 13 Nov 2014 13:10:48 +0800
Message-ID: <20141113051048.GA1801@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@suug.ch>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34950 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbaKMFK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 00:10:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My editor spewed garbage that looked like memory corruption on
my screen.  It turns out that a number of occurences of "fi" got
turned into a ligature.
   =20
This patch replaces these ligatures with the ASCII letters "fi".
   =20
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 081be3b..624a0b7 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -230,7 +230,7 @@ int rhashtable_expand(struct rhashtable *ht, gfp_t =
flags)
 	ht->shift++;
=20
 	/* For each new bucket, search the corresponding old bucket
-	 * for the =EF=AC=81rst entry that hashes to the new bucket, and
+	 * for the first entry that hashes to the new bucket, and
 	 * link the new bucket to that entry. Since all the entries
 	 * which will end up in the new bucket appear in the same
 	 * old bucket, this constructs an entirely valid new hash
@@ -248,8 +248,8 @@ int rhashtable_expand(struct rhashtable *ht, gfp_t =
flags)
 	}
=20
 	/* Publish the new table pointer. Lookups may now traverse
-	 * the new table, but they will not bene=EF=AC=81t from any
-	 * additional ef=EF=AC=81ciency until later steps unzip the buckets.
+	 * the new table, but they will not benefit from any
+	 * additional efficiency until later steps unzip the buckets.
 	 */
 	rcu_assign_pointer(ht->tbl, new_tbl);
=20
@@ -306,14 +306,14 @@ int rhashtable_shrink(struct rhashtable *ht, gfp_=
t flags)
=20
 	ht->shift--;
=20
-	/* Link each bucket in the new table to the =EF=AC=81rst bucket
+	/* Link each bucket in the new table to the first bucket
 	 * in the old table that contains entries which will hash
 	 * to the new bucket.
 	 */
 	for (i =3D 0; i < ntbl->size; i++) {
 		ntbl->buckets[i] =3D tbl->buckets[i];
=20
-		/* Link each bucket in the new table to the =EF=AC=81rst bucket
+		/* Link each bucket in the new table to the first bucket
 		 * in the old table that contains entries which will hash
 		 * to the new bucket.
 		 */

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
