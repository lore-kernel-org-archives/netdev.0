From: "Catalin(ux aka Dino) BOIE" <util@deuroconsult.ro>
Subject: [PATCH] rtnl_unlock/lock in sch_api.c
Date: Mon, 28 Mar 2005 17:25:51 +0300 (EEST)
Message-ID: <Pine.LNX.4.62.0503281720430.20453@webhosting.rdsbv.ro>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1646943047-1742722255-1112019951=:20453"
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1646943047-1742722255-1112019951=:20453
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed

Hello!

Trying to load a custom module (same for teql but I didn't tried it)
whan the qdisc module is not loaded, makes tc hang.
This is because qdisc_create aquires rtnl_sem and then tries to load a 
module that tries to register_netdev (that tries to aquire the same 
rtnl_sem).
Applying this patch makes the problem go away.

Signed-off-by: Catalin(ux aka Dino) BOIE <catab at umbrella.ro>

Please apply.

Thanks!

---
Catalin(ux aka Dino) BOIE
catab at deuroconsult.ro
http://kernel.umbrella.ro/
---1646943047-1742722255-1112019951=:20453
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=rt_unlock_in_sch_api.patch
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.62.0503281725510.20453@webhosting.rdsbv.ro>
Content-Description: 
Content-Disposition: attachment; filename=rt_unlock_in_sch_api.patch

LS0tIGxpbnV4L25ldC9zY2hlZC9zY2hfYXBpLmMub3JpZwkyMDA1LTAzLTI4
IDE2OjMyOjU3LjAwMDAwMDAwMCArMDMwMA0KKysrIGxpbnV4L25ldC9zY2hl
ZC9zY2hfYXBpLmMJMjAwNS0wMy0yOCAxNjozODoxNy4wMDAwMDAwMDAgKzAz
MDANCkBAIC00MDQsMTggKzQwNCwyOCBAQCBxZGlzY19jcmVhdGUoc3RydWN0
IG5ldF9kZXZpY2UgKmRldiwgdTMyDQogCXN0cnVjdCBRZGlzY19vcHMgKm9w
czsNCiAJaW50IHNpemU7DQogDQorCWVyciA9IC1FSU5WQUw7DQogCW9wcyA9
IHFkaXNjX2xvb2t1cF9vcHMoa2luZCk7DQogI2lmZGVmIENPTkZJR19LTU9E
DQotCWlmIChvcHM9PU5VTEwgJiYgdGNhW1RDQV9LSU5ELTFdICE9IE5VTEwp
IHsNCisJaWYgKG9wcyA9PSBOVUxMICYmIGtpbmQgIT0gTlVMTCkgew0KIAkJ
Y2hhciBuYW1lW0lGTkFNU0laXTsNCiAJCWlmIChydGF0dHJfc3RybGNweShu
YW1lLCBraW5kLCBJRk5BTVNJWikgPCBJRk5BTVNJWikgew0KKwkJCS8qIE11
c3QgZHJvcCBydG5sIHNlbSBiZWNhdXNlIHJlcXVlc3RfbW9kdWxlDQorCQkJ
ICogY2FuIHRyeSB0byBhcXVpcmUgcnRubCBzZW0gKHNlZSB0ZXFsIGZvcg0K
KwkJCSAqIGV4YW1wbGUpDQorCQkJICovDQorCQkJcnRubF91bmxvY2soKTsN
CiAJCQlyZXF1ZXN0X21vZHVsZSgic2NoXyVzIiwgbmFtZSk7DQorCQkJcnRu
bF9sb2NrKCk7DQogCQkJb3BzID0gcWRpc2NfbG9va3VwX29wcyhraW5kKTsN
CisJCQlpZiAob3BzICE9IE5VTEwpIHsNCisJCQkJbW9kdWxlX3B1dChvcHMt
Pm93bmVyKTsNCisJCQkJZXJyID0gLUVBR0FJTjsNCisJCQl9DQogCQl9DQog
CX0NCiAjZW5kaWYNCiANCi0JZXJyID0gLUVJTlZBTDsNCiAJaWYgKG9wcyA9
PSBOVUxMKQ0KIAkJZ290byBlcnJfb3V0Ow0KIA0K

---1646943047-1742722255-1112019951=:20453--
