From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 01/11] sfc: Implement 128-bit writes for efx_writeo_page
Date: Thu, 12 Jul 2012 09:45:05 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F7D@saturn3.aculab.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com> <1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48258 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753204Ab2GLIrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 04:47:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 27632-06 for <netdev@vger.kernel.org>;
 Thu, 12 Jul 2012 09:47:04 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1342048518.2613.60.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBv
d25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBCZW4gSHV0Y2hpbmdzDQo+IFNlbnQ6
IDEyIEp1bHkgMjAxMiAwMDoxNQ0KPiBUbzogRGF2aWQgTWlsbGVyDQo+IENjOiBuZXRkZXZAdmdl
ci5rZXJuZWwub3JnOyBsaW51eC1uZXQtZHJpdmVyc0Bzb2xhcmZsYXJlLmNvbQ0KPiBTdWJqZWN0
OiBbUEFUQ0ggbmV0LW5leHQgMDEvMTFdIHNmYzogSW1wbGVtZW50IDEyOC1iaXQgd3JpdGVzIGZv
cg0KPiBlZnhfd3JpdGVvX3BhZ2UNCj4gDQo+IEFkZCBzdXBwb3J0IGZvciB3cml0aW5nIGEgVFgg
ZGVzY3JpcHRvciB0byB0aGUgTklDIGluIG9uZSBQQ0llDQo+IHRyYW5zYWN0aW9uIG9uIHg4Nl82
NCBtYWNoaW5lcy4NCi4uLg0KPiArc3RhdGljIGlubGluZSB2b2lkIF9lZnhfd3JpdGVvKHN0cnVj
dCBlZnhfbmljICplZngsIGVmeF9sZV8xMjggdmFsdWUsDQo+ICsJCQkgICAgICAgdW5zaWduZWQg
aW50IHJlZykNCj4gK3sNCi4uLg0KPiArfQ0KDQpXb3VsZG4ndCBpdCBiZSBiZXR0ZXIgdG8gcHV0
IGNvZGUgdGhpcyBpbiBzb21lIGdlbmVyaWMgaGVhZGVyDQp3aGVyZSBpdCBjYW4gYmUgdXNlZCBi
eSBvdGhlciBkcml2ZXJzPw0KDQpTb21lIGFyY2hpdGVjdHVyZXMvY3B1cyBoYXZlIGRtYSBlbmdp
bmVzIGFzc29jaWF0ZWQgd2l0aCB0aGUNClBDSWUgaW50ZXJmYWNlIHRoYW4gY2FuIGJlIHVzZWQg
dG8gcmVxdWVzdCBsb25nZXIgUENJZSB0cmFuc2FjdGlvbnMuDQoNClNvIHlvdSBwcm9iYWJseSBu
ZWVkIGEgdHJhbnNmZXIgbGVuZ3RoIGFzIHdlbGwuDQoNCkkgc3VzcGVjdCB0aGF0IGl0IGlzIG5l
dmVyIHdvcnRoIHVzaW5nIGFuIGludGVycnVwdCBmb3INCnRoZSBjb21wbGV0aW9uIG9mIHN1Y2gg
ZG1hIC0gYWx0aG91Z2ggc3BsaXR0aW5nIHRoZSByZXF1ZXN0DQphbmQgd2FpdCB3b3VsZCBhbGxv
dyB0aGUgY2FsbGVyIHRvIG92ZXJsYXAgb3BlcmF0aW9ucy4NCg0KV2l0aCBhIGRtYSBpbnRlcmZh
Y2UgaXQgaXMgd29ydGggdXBkYXRpbmcgbXVsdGlwbGUgcmluZw0KZW50cmllcyBhdCBvbmUsIGFu
ZCByZWFkaW5nIG11bHRpcGxlIGVudHJpZXMgZm9yIHN0YXR1cy4NCg0KCURhdmlkDQoNCg==
