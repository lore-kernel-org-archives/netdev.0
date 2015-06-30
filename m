From: Maninder Singh <maninder1.s@samsung.com>
Subject: Re: [PATCH 1/1] igb: Use ARRAY_SIZE instead fo sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 08:01:57 +0000 (GMT)
Message-ID: <1652907052.50321435651311854.JavaMail.weblogic@ep2mlwas04a>
Reply-To: maninder1.s@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: base64
Cc: "jeffrey.t.kirsher@intel.com" <jeffrey.t.kirsher@intel.com>,
	"jesse.brandeburg@intel.com" <jesse.brandeburg@intel.com>,
	"shannon.nelson@intel.com" <shannon.nelson@intel.com>,
	"carolyn.wyborny@intel.com" <carolyn.wyborny@intel.com>,
	"donald.c.skidmore@intel.com" <donald.c.skidmore@intel.com>,
	"matthew.vick@intel.com" <matthew.vick@intel.com>,
	"john.ronciak@intel.com" <john.ronciak@intel.com>,
	"mitch.a.williams@intel.com" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:50090 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799AbbF3ICS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 04:02:18 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NQQ00GR2ZNT0Z80@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 30 Jun 2015 17:02:17 +0900 (KST)
MIME-version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgSm9lLA0KDQo+PiBVc2UgQVJSQVlfU0laRSBpbnN0ZWFkIGZvIHNpemVvZihhKS9zaXplb2Yo
YVswXSkNCj4NCj5JIHRoaW5rIGFsbCBvZiB0aGVzZSAjZGVmaW5lcyBzaG91bGQgYmUgcmVtb3Zl
ZCBpbnN0ZWFkDQo+YXMgdGhleSBhcmUgYWxsIHVzZWQgb25seSBvbmNlLg0KDQpJZiB3ZSByZXBs
Y2FzZSBvbmx5IEFSUkFZX1NJWkUgdGhlbiBjb29kIHdpbGwgbG9vayBhbGlrZQ0KdG8gZHJpdmVy
cy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBlL3BoeS5jDQoNCkFuZCBpZiB3ZSBoYXZlIHRvIHJl
bW92ZSB0aGVzZSAjZGVmaW5lcyAsIHRoZW4gd2UgY2FuIGFsc28gcmVtb3ZlIGl0IGZyb20gDQpk
cml2ZXJzL25ldC9ldGhlcm5ldC9pbnRlbC9lMTAwMGUvcGh5LmMgDQoNCkJlY2F1c2Ugc2FtZSBv
cGVyYXRpb25zIGFuZCBzYW1lIHVzYWdlIGlzIHRoZXJlIGluIGJvdGggZmlsZXMuDQp3aGF0IHNh
eT8NCg0KPj4gZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9lMTAw
MF9waHkuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVsL2lnYi9lMTAwMF9waHkuYw0KPltd
DQo+PiBAQCAtMzcsOCArMzcsNyBAQCBzdGF0aWMgczMyICBpZ2Jfc2V0X21hc3Rlcl9zbGF2ZV9t
b2RlKHN0cnVjdCBlMTAwMF9odyAqaHcpOw0KPj4gIHN0YXRpYyBjb25zdCB1MTYgZTEwMDBfbTg4
X2NhYmxlX2xlbmd0aF90YWJsZVtdID0gew0KPj4gIAkwLCA1MCwgODAsIDExMCwgMTQwLCAxNDAs
IEUxMDAwX0NBQkxFX0xFTkdUSF9VTkRFRklORUQgfTsNCj4+ICAjZGVmaW5lIE04OEUxMDAwX0NB
QkxFX0xFTkdUSF9UQUJMRV9TSVpFIFwNCj4+IC0JKHNpemVvZihlMTAwMF9tODhfY2FibGVfbGVu
Z3RoX3RhYmxlKSAvIFwNCj4+IC0Jc2l6ZW9mKGUxMDAwX204OF9jYWJsZV9sZW5ndGhfdGFibGVb
MF0pKQ0KPj4gKwlBUlJBWV9TSVpFKGUxMDAwX204OF9jYWJsZV9sZW5ndGhfdGFibGUpDQo+PiAg
