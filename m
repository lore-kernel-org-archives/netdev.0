From: Julian Anastasov <ja@ssi.bg>
Subject: [2.6 PATCH] ipvs - avoid NULL ptr deref in __ip_vs_get_out_rt
Date: Wed, 12 Nov 2003 01:46:43 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311120134540.2506-200000@u.domain.uli>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="1607745702-1855971336-1068594403=:2506"
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>,
        morpheus <morpheus@theendless.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.
  Send mail to mime@docserver.cac.washington.edu for more info.

--1607745702-1855971336-1068594403=:2506
Content-Type: TEXT/PLAIN; charset=US-ASCII


	Hello,

	The attached patch fixes the problem as reported from
Kris (morpheus at theendless.org) under subject "linux-2.6.0-test9 and 
IPVS (Kernel OOPS) with sync daemon started.". Kris reported that
the fix works. It fixes a copy-and-paste bug which leads to dereferencing 
a NULL ptr in __ip_vs_get_out_rt.

Regards

--
Julian Anastasov <ja@ssi.bg>

--1607745702-1855971336-1068594403=:2506
Content-Type: TEXT/PLAIN; charset=US-ASCII; name="rt-1.diff"
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.44.0311120146430.2506@u.domain.uli>
Content-Description: fix dest rt
Content-Disposition: attachment; filename="rt-1.diff"

IyBUaGlzIGlzIGEgQml0S2VlcGVyIGdlbmVyYXRlZCBwYXRjaCBmb3IgdGhl
IGZvbGxvd2luZyBwcm9qZWN0Og0KIyBQcm9qZWN0IE5hbWU6IExpbnV4IGtl
cm5lbCB0cmVlDQojIFRoaXMgcGF0Y2ggZm9ybWF0IGlzIGludGVuZGVkIGZv
ciBHTlUgcGF0Y2ggY29tbWFuZCB2ZXJzaW9uIDIuNSBvciBoaWdoZXIuDQoj
IFRoaXMgcGF0Y2ggaW5jbHVkZXMgdGhlIGZvbGxvd2luZyBkZWx0YXM6DQoj
CSAgICAgICAgICAgQ2hhbmdlU2V0CTEuMTM0OSAgLT4gMS4xMzUwIA0KIwlu
ZXQvaXB2NC9pcHZzL2lwX3ZzX3htaXQuYwkxLjYgICAgIC0+IDEuNyAgICAN
CiMNCiMgVGhlIGZvbGxvd2luZyBpcyB0aGUgQml0S2VlcGVyIENoYW5nZVNl
dCBMb2cNCiMgLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0NCiMgMDMvMTEvMTIJamFAc3NpLmJnCTEuMTM1MA0KIyBbSVBW
U106IGF2b2lkIE5VTEwgcHRyIGRlcmVmIGZvciBkZXN0IGluIF9faXBfdnNf
Z2V0X291dF9ydA0KIyAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LS0tLS0tLS0tLS0tLQ0KIw0KZGlmZiAtTnJ1IGEvbmV0L2lwdjQvaXB2cy9p
cF92c194bWl0LmMgYi9uZXQvaXB2NC9pcHZzL2lwX3ZzX3htaXQuYw0KLS0t
IGEvbmV0L2lwdjQvaXB2cy9pcF92c194bWl0LmMJV2VkIE5vdiAxMiAwMTow
MDozNSAyMDAzDQorKysgYi9uZXQvaXB2NC9pcHZzL2lwX3ZzX3htaXQuYwlX
ZWQgTm92IDEyIDAxOjAwOjM1IDIwMDMNCkBAIC05OCw3ICs5OCw3IEBADQog
CQkJLm9pZiA9IDAsDQogCQkJLm5sX3UgPSB7DQogCQkJCS5pcDRfdSA9IHsN
Ci0JCQkJCS5kYWRkciA9IGRlc3QtPmFkZHIsDQorCQkJCQkuZGFkZHIgPSBj
cC0+ZGFkZHIsDQogCQkJCQkuc2FkZHIgPSAwLA0KIAkJCQkJLnRvcyA9IHJ0
b3MsIH0gfSwNCiAJCX07DQo=
--1607745702-1855971336-1068594403=:2506--
