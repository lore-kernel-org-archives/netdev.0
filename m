From: Jamal Hadi Salim <hadi@znyx.com>
Subject: Re: patch: policy update by id
Date: Wed, 27 Apr 2005 08:27:06 -0400
Message-ID: <1114604826.7670.24.camel@localhost.localdomain>
References: <1114602874.7670.4.camel@localhost.localdomain>
	 <1114604657.7670.22.camel@localhost.localdomain>
Reply-To: hadi@znyx.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zfQAy5DITNpt42sShRMm"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1114604657.7670.22.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-zfQAy5DITNpt42sShRMm
Content-Transfer-Encoding: 7bit
Content-Type: text/plain


dammit. here it is now compiling ;->

cheers,
jamal

--=-zfQAy5DITNpt42sShRMm
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=polid_p
Content-Type: text/plain; name=polid_p; charset=utf-8

--- /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 11:32:13	1.1
+++ /usr/src/26117-mod/net/xfrm/xfrm_policy.c	2005/04/27 12:25:24
@@ -345,7 +345,9 @@
 
 	write_lock_bh(&xfrm_policy_lock);
 	for (p = &xfrm_policy_list[dir]; (pol=*p)!=NULL;) {
-		if (!delpol && memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0) {
+		if (!delpol && 
+		((!excl && policy->index && (policy->index == pol->index)) || 
+		 (memcmp(&policy->selector, &pol->selector, sizeof(pol->selector)) == 0))) {
 			if (excl) {
 				write_unlock_bh(&xfrm_policy_lock);
 				return -EEXIST;

--=-zfQAy5DITNpt42sShRMm--
