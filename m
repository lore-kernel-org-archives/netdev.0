From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: multicast loop with include filters fix [PATCH]
Date: Fri, 23 Jan 2004 13:27:40 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF047517E8.F84E09DF-ON88256E24.006FFBA6@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	Boundary="0__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36"
Cc: netdev@oss.sgi.com, stevenh@xsmail.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--0__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36
Content-type: multipart/alternative;
	Boundary="1__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36"

--1__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36
Content-type: text/plain; charset=US-ASCII





Dave,
      I had a stupid typo in the v6 side of this patch, which
reverses the sense of the check; here's a patch to fix the patch.
Sorry about that.

                        +-DLS

--- linux-2.6.2-rc1F1/net/ipv6/mcast.c.orig     2004-01-23 12:10:55.615139688 -0800
+++ linux-2.6.2-rc1F1/net/ipv6/mcast.c    2004-01-23 12:11:15.477120208 -0800
@@ -918,7 +918,7 @@
                        break;
            }
            if (mc) {
-                 if (ipv6_addr_any(src_addr)) {
+                 if (!ipv6_addr_any(src_addr)) {
                        struct ip6_sf_list *psf;

                        spin_lock_bh(&mc->mca_lock);

(See attached file: mldfix.patch)
--1__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36
Content-type: text/html; charset=US-ASCII
Content-Disposition: inline

<html><body>
<p>Dave,<br>
	I had a stupid typo in the v6 side of this patch, which<br>
reverses the sense of the check; here's a patch to fix the patch.<br>
Sorry about that.<br>
<br>
				+-DLS<br>
<br>
--- linux-2.6.2-rc1F1/net/ipv6/mcast.c.orig	2004-01-23 12:10:55.615139688 -0800<br>
+++ linux-2.6.2-rc1F1/net/ipv6/mcast.c	2004-01-23 12:11:15.477120208 -0800<br>
@@ -918,7 +918,7 @@<br>
 				break;<br>
 		}<br>
 		if (mc) {<br>
-			if (ipv6_addr_any(src_addr)) {<br>
+			if (!ipv6_addr_any(src_addr)) {<br>
 				struct ip6_sf_list *psf;<br>
 <br>
 				spin_lock_bh(&amp;mc-&gt;mca_lock);<br>
<br>
<i>(See attached file: mldfix.patch)</i><br>
</body></html>

--1__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36--


--0__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36
Content-type: application/octet-stream;
	name="mldfix.patch"
Content-Disposition: attachment; filename="mldfix.patch"
Content-ID: <10__=07BBE4B7DFFC7D368f9e8a93df938@us.ibm.com>
Content-transfer-encoding: base64

LS0tIGxpbnV4LTIuNi4yLXJjMUYxL25ldC9pcHY2L21jYXN0LmMub3JpZwkyMDA0LTAxLTIzIDEy
OjEwOjU1LjYxNTEzOTY4OCAtMDgwMAorKysgbGludXgtMi42LjItcmMxRjEvbmV0L2lwdjYvbWNh
c3QuYwkyMDA0LTAxLTIzIDEyOjExOjE1LjQ3NzEyMDIwOCAtMDgwMApAQCAtOTE4LDcgKzkxOCw3
IEBACiAJCQkJYnJlYWs7CiAJCX0KIAkJaWYgKG1jKSB7Ci0JCQlpZiAoaXB2Nl9hZGRyX2FueShz
cmNfYWRkcikpIHsKKwkJCWlmICghaXB2Nl9hZGRyX2FueShzcmNfYWRkcikpIHsKIAkJCQlzdHJ1
Y3QgaXA2X3NmX2xpc3QgKnBzZjsKIAogCQkJCXNwaW5fbG9ja19iaCgmbWMtPm1jYV9sb2NrKTsK


--0__=07BBE4B7DFFC7D368f9e8a93df938690918c07BBE4B7DFFC7D36--
