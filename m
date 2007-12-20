From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: [PATCH] e1000e: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 12:56:16 -0500
Message-ID: <82e4877d0712200956l4126e221qc0cf4720e59ca2a1@mail.gmail.com>
References: <Pine.LNX.4.64.0712182046560.3616@mini.warudkars.net>
	 <476AA0C3.2080503@intel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_24338_16706238.1198173377030"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:28671 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933864AbXLTR4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 12:56:18 -0500
Received: by wr-out-0506.google.com with SMTP id c49so2452873wra.1
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 09:56:17 -0800 (PST)
In-Reply-To: <476AA0C3.2080503@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_24338_16706238.1198173377030
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Dec 20, 2007 12:05 PM, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>
> I can't even apply this patch and the e1000 one... not only is it whitespace
> damaged it is also not properly formatted as patch at all. If you want me to take
> these patches seriously, then please fix the formatting issues.

Sigh - I use Pine, follow Documents/email-clients.txt for the
recommended settings and obviously the pathces are not generated with
whitespace damage at my end as I test those before sending out.

So although I hate to see this happen there is nothing at this moment
that I can do - except for attaching the patch instead of inlining it.
Since they have already been reviewed inline, please see if the
attached patches work for you.

[parag@mini linux-2.6]$ scripts/checkpatch.pl --no-tree
../../Patches/e1000_main.c.patch
total: 0 errors, 0 warnings, 8 lines checked

Your patch has no obvious style problems and is ready for submission.
[parag@mini linux-2.6]$
[parag@mini linux-2.6]$ vim drivers/net/e1000/e1000_main.c
[parag@mini linux-2.6]$ patch -p1 < ../../Patches/e1000_main.c.patch
patching file drivers/net/e1000/e1000_main.c

[parag@mini linux-2.6]$ scripts/checkpatch.pl --no-tree
../../Patches/e1000e-netdev.c.patch
total: 0 errors, 0 warnings, 8 lines checked

Your patch has no obvious style problems and is ready for submission.
[parag@mini linux-2.6]$ patch -p1 < ../../Patches/e1000e-netdev.c.patch
patching file drivers/net/e1000e/netdev.c

Thanks

Parag

------=_Part_24338_16706238.1198173377030
Content-Type: application/octet-stream; name=e1000_main.c.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fafl82630
Content-Disposition: attachment; filename=e1000_main.c.patch

U2lnbmVkLW9mZi1ieTogUGFyYWcgV2FydWRrYXIgPHBhcmFnLndhcnVka2FyQGdtYWlsLmNvbT4K
Ci0tLSBsaW51eC0yLjYvZHJpdmVycy9uZXQvZTEwMDAvZTEwMDBfbWFpbi5jCTIwMDctMTItMDcg
MTA6MDQ6MzkuMDAwMDAwMDAwIC0wNTAwCisrKyBsaW51eC0yLjYtd29yay9kcml2ZXJzL25ldC9l
MTAwMC9lMTAwMF9tYWluLmMJMjAwNy0xMi0xOCAyMDozODozOC4wMDAwMDAwMDAgLTA1MDAKQEAg
LTEwMzAsNyArMTAzMCw3IEBACiAJYWRhcHRlci0+dHhfZmlmb19zdGFsbF90aW1lci5mdW5jdGlv
biA9ICZlMTAwMF84MjU0N190eF9maWZvX3N0YWxsOwogCWFkYXB0ZXItPnR4X2ZpZm9fc3RhbGxf
dGltZXIuZGF0YSA9ICh1bnNpZ25lZCBsb25nKSBhZGFwdGVyOwogCi0JaW5pdF90aW1lcigmYWRh
cHRlci0+d2F0Y2hkb2dfdGltZXIpOworCWluaXRfdGltZXJfZGVmZXJyYWJsZSgmYWRhcHRlci0+
d2F0Y2hkb2dfdGltZXIpOwogCWFkYXB0ZXItPndhdGNoZG9nX3RpbWVyLmZ1bmN0aW9uID0gJmUx
MDAwX3dhdGNoZG9nOwogCWFkYXB0ZXItPndhdGNoZG9nX3RpbWVyLmRhdGEgPSAodW5zaWduZWQg
bG9uZykgYWRhcHRlcjsKIAo=
------=_Part_24338_16706238.1198173377030
Content-Type: application/octet-stream; name=e1000e-netdev.c.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faflgl8n1
Content-Disposition: attachment; filename=e1000e-netdev.c.patch

U2lnbmVkLW9mZi1ieTogUGFyYWcgV2FydWRrYXIgPHBhcmFnLndhcnVka2FyQGdtYWlsLmNvbT4K
Ci0tLSBsaW51eC0yLjYvZHJpdmVycy9uZXQvZTEwMDBlL25ldGRldi5jCTIwMDctMTItMDcgMTA6
MDQ6MzkuMDAwMDAwMDAwIC0wNTAwCisrKyBsaW51eC0yLjYtd29yay9kcml2ZXJzL25ldC9lMTAw
MGUvbmV0ZGV2LmMJMjAwNy0xMi0xOCAyMDo0NTo1OS4wMDAwMDAwMDAgLTA1MDAKQEAgLTM4OTks
NyArMzg5OSw3IEBACiAJCWdvdG8gZXJyX2VlcHJvbTsKIAl9CiAKLQlpbml0X3RpbWVyKCZhZGFw
dGVyLT53YXRjaGRvZ190aW1lcik7CisJaW5pdF90aW1lcl9kZWZlcnJhYmxlKCZhZGFwdGVyLT53
YXRjaGRvZ190aW1lcik7CiAJYWRhcHRlci0+d2F0Y2hkb2dfdGltZXIuZnVuY3Rpb24gPSAmZTEw
MDBfd2F0Y2hkb2c7CiAJYWRhcHRlci0+d2F0Y2hkb2dfdGltZXIuZGF0YSA9ICh1bnNpZ25lZCBs
b25nKSBhZGFwdGVyOwogCg==
------=_Part_24338_16706238.1198173377030--
