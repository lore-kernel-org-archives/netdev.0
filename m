From: Petko Manolov <petkan@nucleusys.com>
Subject: [patch] pegasus.c
Date: Wed, 9 Jan 2008 12:30:28 +0200 (EET)
Message-ID: <alpine.DEB.1.00.0801091222560.3171@bender.nucleusys.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811350-1804620356-1199874628=:3171"
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from n152-u15.cabletel.bg ([89.253.152.15]:59028 "EHLO
	zztop.nucleusys.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750793AbYAILXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 06:23:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811350-1804620356-1199874628=:3171
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII

 	Hi Jeff,

Attached you'll find a patch that is fixing a driver bug triggered when 
malformed string is passed to the 'devid' module parameter.  The expected 
format is:

 	"device_name:vendor_id:device_id:flags"

but it turned out people often type:

 	"somename::0"

instead of:

 	"somename:::0"


cheers,
Petko
---1463811350-1804620356-1199874628=:3171
Content-Type: TEXT/x-diff; name=pegasus.c.patch
Content-Transfer-Encoding: BASE64
Content-ID: <alpine.DEB.1.00.0801091230280.3171@bender.nucleusys.com>
Content-Description: 
Content-Disposition: attachment; filename=pegasus.c.patch

LS0tIGRyaXZlcnMvbmV0L3VzYi9wZWdhc3VzLmMub3JpZwkyMDA4LTAxLTA5
IDEyOjE2OjUyLjAwMDAwMDAwMCArMDIwMA0KKysrIGRyaXZlcnMvbmV0L3Vz
Yi9wZWdhc3VzLmMJMjAwOC0wMS0wOSAxMjoxNjo1OC4wMDAwMDAwMDAgKzAy
MDANCkBAIC0xNDYxLDEyICsxNDYxLDI0IEBAIHN0YXRpYyB2b2lkIHBhcnNl
X2lkKGNoYXIgKmlkKQ0KIA0KIAlpZiAoKHRva2VuID0gc3Ryc2VwKCZpZCwg
IjoiKSkgIT0gTlVMTCkNCiAJCW5hbWUgPSB0b2tlbjsNCisJZWxzZQ0KKwkJ
Z290byBlcnI7DQogCS8qIG5hbWUgbm93IHBvaW50cyB0byBhIG51bGwgdGVy
bWluYXRlZCBzdHJpbmcqLw0KIAlpZiAoKHRva2VuID0gc3Ryc2VwKCZpZCwg
IjoiKSkgIT0gTlVMTCkNCiAJCXZlbmRvcl9pZCA9IHNpbXBsZV9zdHJ0b3Vs
KHRva2VuLCBOVUxMLCAxNik7DQorCWVsc2UNCisJCWdvdG8gZXJyOw0KKw0K
IAlpZiAoKHRva2VuID0gc3Ryc2VwKCZpZCwgIjoiKSkgIT0gTlVMTCkNCiAJ
CWRldmljZV9pZCA9IHNpbXBsZV9zdHJ0b3VsKHRva2VuLCBOVUxMLCAxNik7
DQotCWZsYWdzID0gc2ltcGxlX3N0cnRvdWwoaWQsIE5VTEwsIDE2KTsNCisJ
ZWxzZQ0KKwkJZ290byBlcnI7DQorDQorCWlmIChpZCAhPSBOVUxMKQ0KKwkJ
ZmxhZ3MgPSBzaW1wbGVfc3RydG91bChpZCwgTlVMTCwgMTYpOw0KKwllbHNl
DQorCQlnb3RvIGVycjsNCisNCiAJcHJfaW5mbygiJXM6IG5ldyBkZXZpY2Ug
JXMsIHZlbmRvciBJRCAweCUwNHgsIGRldmljZSBJRCAweCUwNHgsIGZsYWdz
OiAweCV4XG4iLA0KIAkgICAgICAgIGRyaXZlcl9uYW1lLCBuYW1lLCB2ZW5k
b3JfaWQsIGRldmljZV9pZCwgZmxhZ3MpOw0KIA0KQEAgLTE0NzYsNiArMTQ4
OCw3IEBAIHN0YXRpYyB2b2lkIHBhcnNlX2lkKGNoYXIgKmlkKQ0KIAkJcmV0
dXJuOw0KIA0KIAlmb3IgKGk9MDsgdXNiX2Rldl9pZFtpXS5uYW1lOyBpKysp
Ow0KKw0KIAl1c2JfZGV2X2lkW2ldLm5hbWUgPSBuYW1lOw0KIAl1c2JfZGV2
X2lkW2ldLnZlbmRvciA9IHZlbmRvcl9pZDsNCiAJdXNiX2Rldl9pZFtpXS5k
ZXZpY2UgPSBkZXZpY2VfaWQ7DQpAQCAtMTQ4Myw2ICsxNDk2LDExIEBAIHN0
YXRpYyB2b2lkIHBhcnNlX2lkKGNoYXIgKmlkKQ0KIAlwZWdhc3VzX2lkc1tp
XS5tYXRjaF9mbGFncyA9IFVTQl9ERVZJQ0VfSURfTUFUQ0hfREVWSUNFOw0K
IAlwZWdhc3VzX2lkc1tpXS5pZFZlbmRvciA9IHZlbmRvcl9pZDsNCiAJcGVn
YXN1c19pZHNbaV0uaWRQcm9kdWN0ID0gZGV2aWNlX2lkOw0KKw0KKwlyZXR1
cm47DQorDQorZXJyOg0KKwlwcl9pbmZvKCJtYWxmb3JtZWQgJ2RldmlkJyBt
b2R1bGUgcGFyYW1ldGVyXG4iKTsNCiB9DQogDQogc3RhdGljIGludCBfX2lu
aXQgcGVnYXN1c19pbml0KHZvaWQpDQo=

---1463811350-1804620356-1199874628=:3171--
