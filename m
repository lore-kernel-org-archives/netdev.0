From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.12-rc2 9/11] tg3: Fix bug in tg3_set_eeprom()
Date: Mon, 18 Apr 2005 00:57:27 -0700
Message-ID: <1113811047.6504.78.camel@rh4>
References: <04132005193843.8300@laptop> <1113806551.6504.11.camel@rh4>
 <1113809864.6504.58.camel@rh4>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="=-34ThBbzcnc+C1bparKbC"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>, davem@davemloft.net
In-Reply-To: <1113809864.6504.58.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-34ThBbzcnc+C1bparKbC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Fix a bug in tg3_set_eeprom() when the length is less than 4 and the
offset is not 4-byte aligned.

Signed-off-by: Michael Chan <mchan@broadcom.com>

--=-34ThBbzcnc+C1bparKbC
Content-Disposition: attachment;
 filename=tg3-109.patch
Content-Type: text/x-patch;
 charset=utf-8;
 name=tg3-109.patch
Content-Transfer-Encoding: base64

ZGlmZiAtTnJ1IDEwOC9kcml2ZXJzL25ldC90ZzMuYyAxMDkvZHJpdmVycy9uZXQvdGczLmMNCi0t
LSAxMDgvZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNC0xNSAxNzo0ODoyMy4wMDAwMDAwMDAgLTA3
MDANCisrKyAxMDkvZHJpdmVycy9uZXQvdGczLmMJMjAwNS0wNC0xNSAyMToyNjowMi4wMDAwMDAw
MDAgLTA3MDANCkBAIC02NTYwLDEwICs2NTYwLDEyIEBADQogCQlzdGFydCA9IGNwdV90b19sZTMy
KHN0YXJ0KTsNCiAJCWxlbiArPSBiX29mZnNldDsNCiAJCW9mZnNldCAmPSB+MzsNCisJCWlmIChs
ZW4gPCA0KQ0KKwkJCWxlbiA9IDQ7DQogCX0NCiANCiAJb2RkX2xlbiA9IDA7DQotCWlmICgobGVu
ICYgMykgJiYgKChsZW4gPiA0KSB8fCAoYl9vZmZzZXQgPT0gMCkpKSB7DQorCWlmIChsZW4gJiAz
KSB7DQogCQkvKiBhZGp1c3RtZW50cyB0byBlbmQgb24gcmVxdWlyZWQgNCBieXRlIGJvdW5kYXJ5
ICovDQogCQlvZGRfbGVuID0gMTsNCiAJCWxlbiA9IChsZW4gKyAzKSAmIH4zOw0K


--=-34ThBbzcnc+C1bparKbC--
