From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH Linux-2.6.8-rc1] prism54 Fix initialization
	with older firmware
Date: Tue, 27 Jul 2004 19:26:44 +0200
Sender: prism54-devel-bounces@prism54.org
Message-ID: <200407271926.45038.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_UBpBBZ4K8ECFHYG"
Cc: netdev@oss.sgi.com, prism54-devel@prism54.org
Return-path: <prism54-devel-bounces@prism54.org>
To: jgarzik@pobox.com
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--Boundary-00=_UBpBBZ4K8ECFHYG
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Regardless of Luis's comments, we should not try to tamper with this.
Please apply.
Forthcoming fixes may well be able to do better. However, until
more information is known, the fix is correct.
The version OID will be evaluated in a later fix (for info only).

Margit





--Boundary-00=_UBpBBZ4K8ECFHYG
Content-Type: text/x-diff;
  charset="us-ascii";
  name="outputpow.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="outputpow.patch"

diff -Naur linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c
--- linux-2.6.8-01/drivers/net/wireless/prism54/oid_mgt.c	2004-07-15 17:21:42.000000000 +0200
+++ linux-2.6.8-04/drivers/net/wireless/prism54/oid_mgt.c	2004-07-22 09:50:20.000000000 +0200
@@ -613,7 +613,9 @@
 	DOT11_OID_DEFKEYID,
 	DOT11_OID_DOT1XENABLE,
 	OID_INL_DOT11D_CONFORMANCE,
+	/* Do not initialize this - fw < 1.0.4.3 rejects it
 	OID_INL_OUTPUTPOWER,
+	*/
 };
 
 /* update the MAC addr. */

--Boundary-00=_UBpBBZ4K8ECFHYG
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--Boundary-00=_UBpBBZ4K8ECFHYG--
