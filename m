From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 13:12:15 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com> <20130528.233647.1209227470109213894.davem@davemloft.net> <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com> <20130529194438.GY3333@ritirata.org> <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com> <20130530114556.GC2475@ritirata.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>, <amwang@redhat.com>,
	<netdev@vger.kernel.org>, <horms@verge.net.au>
To: "Antonio Quartulli" <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50134 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753245Ab3E3MNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 08:13:31 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17680-08 for <netdev@vger.kernel.org>;
 Thu, 30 May 2013 13:13:27 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <20130530114556.GC2475@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ID4gPiA+ID4gSSB3YW50IHRvIHVzZSBzb21ldGhpbmcgdGhhdCB3aWxsIGVpdGhlciBicmVh
ayB0aGUgYnVpbGQgb3INCj4gPiA+ID4gPiA+IGF1dG9tYXRpY2FsbHkgd29yayBpZiB0aGUgdHlw
ZSBjaGFuZ2VzIGFnYWluLg0KPiA+ID4gPiA+ID4NCj4gPiA+ID4gPiA+IFNvIHNvbWV0aGluZyBs
aWtlICJYID0gKHR5cGVvZihYKSkgfjBVOyIuDQo+ID4gPiA+ID4NCj4gPiA+ID4gPiBJIHRoaW5r
IHlvdSBtZWFuIH4odHlwZW9mKFgpKTAuDQo+ID4gPiA+DQo+ID4gPiA+IEFtIEkgd3Jvbmcgb3Ig
eW91IHNob3VsZCBjYXN0IHRoZSB2YWx1ZSBvbmNlIGFnYWluLCBsaWtlIHRoaXM6DQo+ID4gPiA+
DQo+ID4gPiA+ICgodHlwZW9mKFgpKX4odHlwZW9mKFgpKTApDQo+ID4gPiA+DQo+ID4gPiA+IGJl
Y2F1c2UgdGhlIH4gb3BlcmF0b3Igd2lsbCBpbXBsaWNpdGx5IGNhc3QgdGhlIGFyZ3VtZW50IHRv
IGludCAoaWYgSSByZW1lbWJlcg0KPiA+ID4gPiBjb3JyZWN0bHkpLg0KPiA+ID4NCj4gPiA+IEl0
IHdpbGwgcHJvbW90ZSB0byBhdCBsZWFzdCBpbnQsIGJ1dCB0aGF0IHN0aWxsIHJlc3VsdHMgaW4g
dGhlIHJpZ2h0DQo+ID4gPiB2YWx1ZSBhbmQgZG9lc24ndCBwcm92b2tlIGEgd2FybmluZy4gIFRy
eSB0aGlzIHRlc3QgKHdpdGggLVdhbGwNCj4gPiA+IC1XZXh0cmEpOg0KPiA+ID4NCj4gPiA+ICNp
bmNsdWRlIDxzdGRpby5oPg0KPiA+ID4NCj4gPiA+ICNkZWZpbmUgQUxMX09ORVModikgKH4odHlw
ZW9mKHYpKTApDQo+ID4gPiAvKiAjZGVmaW5lIEFMTF9PTkVTKHYpICh0eXBlb2YodikpfjBVKSAq
Lw0KPiA+ID4NCj4gPiA+IGludCBtYWluKHZvaWQpDQo+ID4gPiB7DQo+ID4gPiAgICAgY2hhciBh
ID0gQUxMX09ORVMoYSk7DQo+ID4gPiAgICAgdW5zaWduZWQgY2hhciBiID0gQUxMX09ORVMoYik7
DQo+ID4gPiAgICAgc2hvcnQgYyA9IEFMTF9PTkVTKGMpOw0KPiA+ID4gICAgIHVuc2lnbmVkIHNo
b3J0IGQgPSBBTExfT05FUyhkKTsNCj4gPiA+ICAgICBpbnQgZSA9IEFMTF9PTkVTKGUpOw0KPiA+
ID4gICAgIHVuc2lnbmVkIGludCBmID0gQUxMX09ORVMoZik7DQo+ID4gPiAgICAgbG9uZyBnID0g
QUxMX09ORVMoZyk7DQo+ID4gPiAgICAgdW5zaWduZWQgbG9uZyBoID0gQUxMX09ORVMoaCk7DQo+
ID4gPiAgICAgbG9uZyBsb25nIGkgPSBBTExfT05FUyhpKTsNCj4gPiA+ICAgICB1bnNpZ25lZCBs
b25nIGxvbmcgaiA9IEFMTF9PTkVTKGopOw0KPiA+ID4NCj4gPiA+ICAgICBwcmludGYoIiVoaHgg
JWhoeCAlaHggJWh4ICV4ICV4ICVseCAlbHggJWxseCAlbGx4XG4iLA0KPiA+ID4gCSAgIGEsIGIs
IGMsIGQsIGUsIGYsIGcsIGgsIGksIGopOw0KPiA+ID4gICAgIHJldHVybiAwOw0KPiA+ID4gfQ0K
PiA+DQo+ID4gVGhlIHByaW50ZiBmb3JtYXQgaXMgbWFza2luZyB0aGUgaGlnaCBiaXRzIGZvciB5
b3UuDQo+ID4gSWYgeW91IGNoYW5nZSB0bzoNCj4gPiAJcHJpbnRmKCIleCAleCAleCAleCAleCAl
eCAlbHggJWx4ICVsbHggJWxseFxuIiwgLi4uKQ0KPiA+IHlvdSBnZXQgZGlmZmVyZW50IHZhbHVl
cy4NCj4gPiBUbyBnZXQgdGhlICdleHBlY3RlZCcgdmFsdWVzIHlvdSBuZWVkIGNhc3RzIGJvdGgg
c2lkZXMgb2YgdGhlIH4NCj4gDQo+IEkgdHJpZWQgd2l0aA0KPiANCj4gMTkgICAgIHByaW50Zigi
JXggJXggJXggJXggJXggJXggJWx4ICVseCAlbGx4ICVsbHhcbiIsDQo+IA0KPiBidXQgSSBzdGls
bCBzZWUgYWxsIEZGLg0KPiANCj4gU29tZXdoZXJlIGVsc2Ugd2UgaGF2ZSBzb21lIGhpZGRlbiBj
b252ZXJzaW9uPw0KDQpPZiBjb3Vyc2UgLSB3ZSBuZWVkIHRvIGxvb2sgYXQgdGhlIHZhbHVlIHRo
YXQgQUxMX09ORVMoKQ0KZ2VuZXJhdGVzIGluIGFuIGV4cHJlc3Npb24uIFNvIHRoZSB0ZXN0IHBy
aW50IG5lZWRzIHRvIGJlOg0KCXByaW50ZigiJWhoeCAlaGh4ICVoeCAlaHggJXggJXggJWx4ICVs
eCAlbGx4ICVsbHhcbiIsDQoJCUFMTF9PTkVTKGEpLCBBTExfT05FUyhiKSwgQUxMX09ORVMoYyks
IEFMTF9PTkVTKGQpLA0KCQlBTExfT05FUyhlKSwgQUxMX09ORVMoZiksIEFMTF9PTkVTKGcpLCBB
TExfT05FUyhoKSwNCgkJQUxMX09ORVMoaSksIEFMTF9PTkVTKGopKTsNCndoaWNoIHRoZW4gZ2l2
ZXMgMHhmZmZmZmZmZiBmb3IgdGhlIGZpcnN0IDQgZW50cmllcy4NCg0KCURhdmlkDQoNCg==
