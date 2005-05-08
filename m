From: pravin <pravin.shelar@gmail.com>
Subject: [PATCH] bug-fix in multipath_drr.c
Date: Sun, 8 May 2005 17:07:26 +0530
Message-ID: <bab43330050508043748790ea2@mail.gmail.com>
Reply-To: pravin <pravin.shelar@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_252_1849904.1115552246650"
Cc: Einar Lueck <elueck@de.ibm.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

------=_Part_252_1849904.1115552246650
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

hi
   This patch fixes a small bug in multipath-drr algorithm registration cod=
e.
In function drr_init :: multipath_alg_register(..) is called with
wrong algorithm ID (AFAIU).

Regards,
Pravin.

------=_Part_252_1849904.1115552246650
Content-Type: text/x-patch; name="multipath_drr-algo-register-fix.patch"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="multipath_drr-algo-register-fix.patch"

U2lnbmVkLW9mZiBieTogUHJhdmluIEIuIFNoZWxhciA8cHJhdmluc0BjYWxzb2Z0aW5jLmNvbT4K
VGhpcyBwYXRjaCBmaXhlcyBhIHNtYWxsIGJ1ZyBpbiBtdWx0aXBhdGhfZHJyIGFsZ29yaXRobSBy
ZWdpc3RyYXRpb24gY29kZS4KCkluZGV4OiBsaW51eC0yLjYuMTItcmM0L25ldC9pcHY0L211bHRp
cGF0aF9kcnIuYwo9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09Ci0tLSBsaW51eC0yLjYuMTItcmM0Lm9yaWcvbmV0L2lwdjQv
bXVsdGlwYXRoX2Ryci5jCTIwMDUtMDUtMDYgMjI6MjA6MzEuMDAwMDAwMDAwIC0wNzAwCisrKyBs
aW51eC0yLjYuMTItcmM0L25ldC9pcHY0L211bHRpcGF0aF9kcnIuYwkyMDA1LTA1LTA4IDAzOjI0
OjAyLjAwMDAwMDAwMCAtMDcwMApAQCAtMjQ0LDcgKzI0NCw3IEBACiAJaWYgKGVycikKIAkJcmV0
dXJuIGVycjsKIAotCWVyciA9IG11bHRpcGF0aF9hbGdfcmVnaXN0ZXIoJmRycl9vcHMsIElQX01Q
X0FMR19SUik7CisJZXJyID0gbXVsdGlwYXRoX2FsZ19yZWdpc3RlcigmZHJyX29wcywgSVBfTVBf
QUxHX0RSUik7CiAJaWYgKGVycikKIAkJZ290byBmYWlsOwogCg==
------=_Part_252_1849904.1115552246650--
