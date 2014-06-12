From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/5] net: sctp: fix incorrect type in gfp
 initializer
Date: Thu, 12 Jun 2014 08:46:44 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725B905@AcuExch.aculab.com>
References: <1402497297-27100-1-git-send-email-dborkman@redhat.com>
	<1402497297-27100-6-git-send-email-dborkman@redhat.com>
	<063D6719AE5E284EB5DD2968C1650D6D1725AF78@AcuExch.aculab.com>
	<5398712C.3000801@redhat.com>
 <CAADnVQLyNCUU0+onEHbygVE-M3WK59uB=NoKWi1V4Rh+6AZkVA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:47164 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932531AbaFLIri (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jun 2014 04:47:38 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17772-01 for <netdev@vger.kernel.org>;
 Thu, 12 Jun 2014 09:47:30 +0100 (BST)
In-Reply-To: <CAADnVQLyNCUU0+onEHbygVE-M3WK59uB=NoKWi1V4Rh+6AZkVA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92DQo+IE9uIFdlZCwgSnVuIDExLCAyMDE0IGF0IDg6MDkg
QU0sIERhbmllbCBCb3JrbWFubiA8ZGJvcmttYW5AcmVkaGF0LmNvbT4gd3JvdGU6DQo+ID4gT24g
MDYvMTEvMjAxNCAwNDo1NSBQTSwgRGF2aWQgTGFpZ2h0IHdyb3RlOg0KPiA+Pg0KPiA+PiBGcm9t
OiBEYW5pZWwgQm9ya21hbm4NCi4uLg0KPiA+Pj4gLS0tIGEvbmV0L3NjdHAvYXNzb2Npb2xhLmMN
Cj4gPj4+ICsrKyBiL25ldC9zY3RwL2Fzc29jaW9sYS5jDQo+ID4+PiBAQCAtMTU5MSw3ICsxNTkx
LDcgQEAgaW50IHNjdHBfYXNzb2NfbG9va3VwX2xhZGRyKHN0cnVjdCBzY3RwX2Fzc29jaWF0aW9u
DQo+ID4+PiAqYXNvYywNCj4gPj4+ICAgLyogU2V0IGFuIGFzc29jaWF0aW9uIGlkIGZvciBhIGdp
dmVuIGFzc29jaWF0aW9uICovDQo+ID4+PiAgIGludCBzY3RwX2Fzc29jX3NldF9pZChzdHJ1Y3Qg
c2N0cF9hc3NvY2lhdGlvbiAqYXNvYywgZ2ZwX3QgZ2ZwKQ0KPiA+Pj4gICB7DQo+ID4+PiAtICAg
ICAgIGJvb2wgcHJlbG9hZCA9IGdmcCAmIF9fR0ZQX1dBSVQ7DQo+ID4+PiArICAgICAgIGJvb2wg
cHJlbG9hZCA9ICEhKGdmcCAmIF9fR0ZQX1dBSVQpOw0KPiA+Pj4gICAgICAgICBpbnQgcmV0Ow0K
PiA+Pj4NCj4gPj4+ICAgICAgICAgLyogSWYgdGhlIGlkIGlzIGFscmVhZHkgYXNzaWduZWQsIGtl
ZXAgaXQuICovDQo+ID4+PiAtLQ0KPiA+Pg0KPiA+Pg0KPiA+PiBJIHdhcyB3b25kZXJpbmcgaWYg
dGhlIGNvbXBpbGVyIHN0aWxsIG1hbmFnZXMgdG8gb3B0aW1pc2UgdGhpcyBpbiBhDQo+ID4+IG1h
bm5lciB0aGF0IGF2b2lkcyBhY3R1YWxseSBjYWxjdWxhdGluZyB0aGUgYm9vbGVhbiB2YWx1ZS4u
Lg0KPiA+Pg0KPiA+PiBTbyBJIGRpc2Fzc2VtYmxlZCB0aGUgY29tcGlsYXRpb24gSSBqdXN0IGRp
ZCBvZiB0aGUgb2xkIGNvZGUgKGdjYyA0LjcuMykuDQo+ID4+IFRoZSBvYmplY3QgY29kZSBsb29r
cyBzdHJhbmdlLg0KPiANCj4gSSdtIG5vdCBzdXJlIHdoZXJlIHlvdSBzZWUgdGhpcy4NCj4gSnVz
dCB0cmllZCB3aXRoIGdjYyA0LjcuMiBvbiB4NjQgYW5kIGFzc2VtYmxlciBjb2RlIGlzIGV4YWN0
bHkgdGhlDQo+IHNhbWUgYmVmb3JlL2FmdGVyIHRoaXMgY2hhbmdlLg0KDQpJIHdhcyBzbGlnaHRs
eSB3b3JyaWVkIGl0IG1pZ2h0IGdlbmVyYXRlIHRoZSBib29sZWFuIHZhbHVlIC0gc29tZXRoaW5n
DQp0aGF0IHlvdSByZWFsbHkgZG9uJ3Qgd2FudCBpdCB0byBkby4NCg0KSSBvbmx5IGxvb2tlZCBh
dCB0aGUgb3V0cHV0IGZvciB0aGUgb2xkIHZlcnNpb24uDQpUaGUgY29tcGlsZXIgc2VlbWVkIHRv
IGhhdmUgY29udmVydGVkOg0KCWlmIChwcmVsb2FkKQ0KCQl4KCk7DQoJeTsNCglpZiAocHJlbG9h
ZCkNCgkJeigpOw0KaW50bzoNCglpZiAocHJlbG9hZCkgew0KCQl4KCk7IHk7IHooKTsNCgl9IGVs
c2Ugew0KCQl5Ow0KCX0NCmFuZCB0aGVuIGZvdW5kIG91dCB0aGF0IHooKSB3YXMgZW1wdHksIGxl
YXZpbmcgdHdvIGNvcGllcyBvZiB5KCkuDQoNCglEYXZpZA0KDQo+ID4+IEkgdGhpbmsgdGhhdCBp
ZHJfcHJlbG9hZF9lbmQoKSBtdXN0IGJlIGFuIGVtcHR5IGlubGluZSBmdW5jdGlvbi4NCj4gPg0K
PiA+DQo+ID4gQ2MnaW5nIFRlanVuLiA7LSkNCj4gPg0KPiA+DQo+ID4+IFRoZSBjb21waWxlciBo
YXMgZHVwbGljYXRlZCB0aGUgY29kZSBiZXR3ZWVuIHRoZSB0d28gJ2lmIChwcmVsb2FkKScNCj4g
Pj4gY2xhdXNlcyAodG8gYXZvaWQgdGhlIGNvbmRpdGlvbmFsIHRlc3QpLCBhbmQgdGhlIGZhaWxl
ZCB0byB0YWlsDQo+ID4+IG1lcmdlIGV2ZXJ5dGhpbmcgaW4gdGhlIGxhdHRlciBzdGFnZXMuDQo+
ID4+IEkgc3VzcGVjdCB0aGF0IGFuIGVtcHR5ICcjZGVmaW5lJyB3b3VsZCBnZW5lcmF0ZSBzbWFs
bGVyIGNvZGUuDQo+ID4+DQo+ID4+ICAgICAgICAgRGF2aWQNCg0K
