From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH] IPv6: (3/5) Set dev->dev_addr and dev->broadcast in ip6_tnls
Date: Mon, 1 Sep 2003 02:48:55 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309010238110.26242-200000@rhea.tcs.hut.fi>
References: <Pine.LNX.4.44.0309010235070.26242-100000@rhea.tcs.hut.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-377318441-847397231-1062373440=:26242"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, <usagi-core@linux-ipv6.org>
In-Reply-To: <Pine.LNX.4.44.0309010235070.26242-100000@rhea.tcs.hut.fi>
Content-ID: <Pine.LNX.4.44.0309010246470.26242@rhea.tcs.hut.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

---377318441-847397231-1062373440=:26242
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.44.0309010246471.26242@rhea.tcs.hut.fi>

Hi,

I just only recently noticed MAX_ADDR_LEN had beed increased to 32. This
means the IPv6 addresses can now be copied into the dev->dev_addr and
dev->broadcast fields, just like the IPv4 addresses are for the other
tunnel drivers. Please apply!

Thanks,
Ville
--
Ville Nuorvala
Research Assistant, Institute of Digital Communications,
Helsinki University of Technology
email: vnuorval@tcs.hut.fi, phone: +358 (0)9 451 5257

---377318441-847397231-1062373440=:26242
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; NAME="ip6_tnl_dev_addr.patch"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0309010244000.26242@rhea.tcs.hut.fi>
Content-Description: 
Content-Disposition: ATTACHMENT; FILENAME="ip6_tnl_dev_addr.patch"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTI3Ni4yOC4yIC0+IDEuMTI3Ni4y
OC4zDQojCW5ldC9pcHY2L2lwNl90dW5uZWwuYwkxLjggICAgIC0+IDEuOSAg
ICANCiMNCiMgVGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5n
ZVNldCBMb2cNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0NCiMgMDMvMDkvMDEJdm51b3J2YWxAZHNsLWhraWd3MWE4
Yi5kaWFsLmluZXQuZmkJMS4xMjc2LjI4LjMNCiMgQ29weSB0dW5uZWwgYWRk
cmVzc2VzIHRvIGRldi0+ZGV2X2FkZHIgYW5kIGRldi0+YnJvYWRjYXN0IGxp
a2UgaW4gdGhlDQojIG90aGVyIHR1bm5lbCBkcml2ZXJzLg0KIyAtLS0tLS0t
LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQ0KIw0KZGlm
ZiAtTnJ1IGEvbmV0L2lwdjYvaXA2X3R1bm5lbC5jIGIvbmV0L2lwdjYvaXA2
X3R1bm5lbC5jDQotLS0gYS9uZXQvaXB2Ni9pcDZfdHVubmVsLmMJTW9uIFNl
cCAgMSAwMTo1Nzo1OCAyMDAzDQorKysgYi9uZXQvaXB2Ni9pcDZfdHVubmVs
LmMJTW9uIFNlcCAgMSAwMTo1Nzo1OCAyMDAzDQpAQCAtODUxLDYgKzg1MSwx
MCBAQA0KIAlzdHJ1Y3QgbmV0X2RldmljZSAqZGV2ID0gdC0+ZGV2Ow0KIAlz
dHJ1Y3QgaXA2X3RubF9wYXJtICpwID0gJnQtPnBhcm1zOw0KIAlzdHJ1Y3Qg
Zmxvd2kgKmZsOw0KKw0KKwltZW1jcHkoJmRldi0+ZGV2X2FkZHIsICZwLT5s
YWRkciwgc2l6ZW9mKHN0cnVjdCBpbjZfYWRkcikpOw0KKwltZW1jcHkoJmRl
di0+YnJvYWRjYXN0LCAmcC0+cmFkZHIsIHNpemVvZihzdHJ1Y3QgaW42X2Fk
ZHIpKTsNCisNCiAJLyogU2V0IHVwIGZsb3dpIHRlbXBsYXRlICovDQogCWZs
ID0gJnQtPmZsOw0KIAlpcHY2X2FkZHJfY29weSgmZmwtPmZsNl9zcmMsICZw
LT5sYWRkcik7DQpAQCAtMTA5MywxMCArMTA5Nyw3IEBADQogCWRldi0+bXR1
ID0gRVRIX0RBVEFfTEVOIC0gc2l6ZW9mIChzdHJ1Y3QgaXB2Nmhkcik7DQog
CWRldi0+ZmxhZ3MgfD0gSUZGX05PQVJQOw0KIAlkZXYtPmlmbGluayA9IDA7
DQotCS8qIEhtbS4uLiBNQVhfQUREUl9MRU4gaXMgOCwgc28gdGhlIGlwdjYg
YWRkcmVzc2VzIGNhbid0IGJlDQotCSAgIGNvcGllZCB0byBkZXYtPmRldl9h
ZGRyIGFuZCBkZXYtPmJyb2FkY2FzdCwgbGlrZSB0aGUgaXB2NA0KLQkgICBh
ZGRyZXNzZXMgd2VyZSBpbiBpcGlwLmMsIGlwX2dyZS5jIGFuZCBzaXQuYy4g
Ki8NCi0JZGV2LT5hZGRyX2xlbiA9IDA7DQorCWRldi0+YWRkcl9sZW4gPSBz
aXplb2Yoc3RydWN0IGluNl9hZGRyKTsNCiB9DQogDQogDQo=
---377318441-847397231-1062373440=:26242--
