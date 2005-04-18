From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.12-rc2 4/11] tg3: Fix tg3_set_power_state()
Date: Mon, 18 Apr 2005 00:28:44 -0700
Message-ID: <1113809324.6504.48.camel@rh4>
References: <04132005193843.8300@laptop> <1113806551.6504.11.camel@rh4>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-g0vpx+P/5OCrNfLGDNB3"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net
In-Reply-To: <1113806551.6504.11.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-g0vpx+P/5OCrNfLGDNB3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Fix tg3_set_power_state to drive GPIOs properly based on the
TG3_FLAG_EEPROM_WRITE_PROTECT flag. Some delays are also added after D0
and D3 power state changes.

Signed-off-by: Michael Chan <mchan@broadcom.com>

--=-g0vpx+P/5OCrNfLGDNB3
Content-Disposition: attachment;
 filename=tg3-104.patch
Content-Transfer-Encoding: base64
Content-Type: text/x-patch;
 charset=utf-8;
 name=tg3-104.patch

ZGlmZiAtTnJ1IDEwMy9kcml2ZXJzL25ldC90ZzMuYyAxMDQvZHJpdmVycy9uZXQvdGczLmMNCi0t
LSAxMDMvZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNC0xNSAxNTowMTozNy4wMDAwMDAwMDAgLTA3
MDANCisrKyAxMDQvZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNC0xNSAxNjozNjoyMy4wMDAwMDAw
MDAgLTA3MDANCkBAIC0xMDA1LDggKzEwMDUsMTMgQEANCiAJCXBjaV93cml0ZV9jb25maWdfd29y
ZCh0cC0+cGRldiwNCiAJCQkJICAgICAgcG0gKyBQQ0lfUE1fQ1RSTCwNCiAJCQkJICAgICAgcG93
ZXJfY29udHJvbCk7DQotCQl0dzMyX2YoR1JDX0xPQ0FMX0NUUkwsIHRwLT5ncmNfbG9jYWxfY3Ry
bCk7DQotCQl1ZGVsYXkoMTAwKTsNCisJCXVkZWxheSgxMDApOwkvKiBEZWxheSBhZnRlciBwb3dl
ciBzdGF0ZSBjaGFuZ2UgKi8NCisNCisJCS8qIFN3aXRjaCBvdXQgb2YgVmF1eCBpZiBpdCBpcyBu
b3QgYSBMT00gKi8NCisJCWlmICghKHRwLT50ZzNfZmxhZ3MgJiBURzNfRkxBR19FRVBST01fV1JJ
VEVfUFJPVCkpIHsNCisJCQl0dzMyX2YoR1JDX0xPQ0FMX0NUUkwsIHRwLT5ncmNfbG9jYWxfY3Ry
bCk7DQorCQkJdWRlbGF5KDEwMCk7DQorCQl9DQogDQogCQlyZXR1cm4gMDsNCiANCkBAIC0xMTUx
LDYgKzExNTYsNyBAQA0KIA0KIAkvKiBGaW5hbGx5LCBzZXQgdGhlIG5ldyBwb3dlciBzdGF0ZS4g
Ki8NCiAJcGNpX3dyaXRlX2NvbmZpZ193b3JkKHRwLT5wZGV2LCBwbSArIFBDSV9QTV9DVFJMLCBw
b3dlcl9jb250cm9sKTsNCisJdWRlbGF5KDEwMCk7CS8qIERlbGF5IGFmdGVyIHBvd2VyIHN0YXRl
IGNoYW5nZSAqLw0KIA0KIAl0ZzNfd3JpdGVfc2lnX3Bvc3RfcmVzZXQodHAsIFJFU0VUX0tJTkRf
U0hVVERPV04pOw0KIA0K


--=-g0vpx+P/5OCrNfLGDNB3--
