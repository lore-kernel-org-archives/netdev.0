From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: net/usb/ax88179_178a driver broken in linux-3.12
Date: Tue, 19 Nov 2013 10:04:11 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7431@saturn3.aculab.com>
References: <52890C7E.6000607@pobox.com> <52891178.2080509@pobox.com> <52891341.4020403@pobox.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742B@saturn3.aculab.com> <AE90C24D6B3A694183C094C60CF0A2F6026B742F@saturn3.aculab.com> <528A9A36.50903@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
To: "Mark Lord" <mlord@pobox.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Ming Lei" <ming.lei@canonical.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42048 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751722Ab3KSKFE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Nov 2013 05:05:04 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 20680-10 for <netdev@vger.kernel.org>;
 Tue, 19 Nov 2013 10:05:01 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <528A9A36.50903@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBNYXJrIExvcmQNCj4gT24gMTMtMTEtMTggMDg6MzIgQU0sIERhdmlkIExhaWdodCB3
cm90ZToNCj4gPj4gRnJvbTogRGF2aWQgTGFpZ2h0DQo+ID4+PiBPbiAxMy0xMS0xNyAwMTo1NiBQ
TSwgTWFyayBMb3JkIHdyb3RlOg0KPiA+Pj4+IE9uIDEzLTExLTE3IDAxOjM1IFBNLCBNYXJrIExv
cmQgd3JvdGU6DQo+ID4+Pj4+IFRoZSBVU0IzIG5ldHdvcmsgYWRhcHRlciBsb2NrcyB1cCBjb25z
aXN0ZW50bHkgZm9yIG1lIGhlcmUgaW4gMy4xMiwNCj4gPj4+Pj4gYnV0IHdhcyB3b3JraW5nIHdp
dGhvdXQgaXNzdWVzIGluIDMuMTEueA0KPiA+Pg0KPiA+PiBUaGUgeGhjaSBkcml2ZXIgaXMgd2Vs
bCBicm9rZW4gaW4gMy4xMi4NCj4gPg0KPiA+IFRvIGNvcnJlY3QgbXlzZWxmLi4uDQo+ID4NCj4g
PiBUaGUgeGhjaSBkcml2ZXIgaGFzIG5ldmVyIGNvcnJlY3RseSBzdXBwb3J0IHNjYXR0ZXItZ2F0
aGVyIHJlcXVlc3RzLg0KPiA+IEluIDMuMTIgY29kZSB3YXMgYWRkZWQgdG8gdXNibmV0IHRvIGdl
bmVyYXRlIFNHIHRyYW5zbWl0cywgYW5kIHRvIHRoZQ0KPiA+IGF4ODgxNzlfMTc4YSBkcml2ZXIg
dG8gdXNlIHRoZW0uDQo+ID4gVENQIHNlZ21lbnRhdGlvbiBvZmZsb2FkIHdhcyB0aGVuIGVuYWJs
ZWQgLSB3aXRoIGRvZXMgZ2VuZXJhdGUNCj4gPiBTRyB0cmFuc2ZlcnMuDQo+ID4NCj4gPiBTRyB0
cmFuc2ZlcnMgZm9yICdkaXNrcycgYWxtb3N0IGNlcnRhaW5seSB3b3JrIGJlY2F1c2UgdGhlDQo+
ID4gZnJhZ21lbnQgYm91bmRhcmllcyBhcmUgJ2FkZXF1YXRlbHkgYWxpZ25lZCcuDQo+ID4NCj4g
PiAJRGF2aWQNCj4gPg0KPiANCj4gV2VsbCwgdGhhdCdzIGFsbCB2ZXJ5IG5pY2UgYW5kIHdoYXRu
b3QsDQo+IGV4Y2VwdCB0aGUgYXg4ODE3OV8xNzhhIGRyaXZlciBzdGlsbCBkb2VzIG5vdCB3b3Jr
IGluIGxpbnV4LTMuMTIsDQo+IHdoZXJlYXMgaXQgd29ya3MgZmluZSBpbiBhbGwgZWFybGllciBr
ZXJuZWxzLg0KPiANCj4gVGhhdCdzIGEgcmVncmVzc2lvbi4NCj4gQW5kIGEgc2ltcGxlIHJldmVy
dCAoZWFybGllciBpbiB0aGlzIHRocmVhZCkgZml4ZXMgaXQuDQo+IA0KPiBTby4uIGxldCdzIHJl
dmVydCBpdCBmb3Igbm93LCB1bnRpbCBhIHByb3BlciB4aGNpIGNvbXBhdGlibGUgcGF0Y2ggaXMg
cHJvZHVjZWQuDQoNCldoaWNoIGNoYW5nZXMgZGlkIHlvdSByZXZlcnQ/DQpJIHRoaW5rIHlvdSBt
dXN0IGhhdmUgZ29uZSByaWdodCBiYWNrIHRvIHRoZSB2ZXJzaW9uIHRoYXQgZG9lc24ndCBzbyBz
Y2F0dGVyLWdhdGhlci4NCg0KVGhlcmUgaXMgYSBwYXRjaCB0byB4aGNpLXJpbmcuYyB0aGF0IHNo
b3VsZCBmaXggdGhlIFNHIHByb2JsZW0uDQpodHRwOi8vd3d3LnNwaW5pY3MubmV0L2xpc3RzL2xp
bnV4LXVzYi9tc2c5NzE3Ni5odG1sDQoNCkkgdGhpbmsgaXQgc2hvdWxkIGFwcGx5IHRvIHRoZSAz
LjEyIHNvdXJjZXMuDQoNCk5vdGUgdGhhdCB3aXRoIG9sZGVyIGtlcm5lbHMgdGhlIGFzaXggY2Fy
ZCBJIGhhdmUgd2lsbCBkcm9wL2Rpc2NhcmQNCnNob3J0IGJ1cnN0cyBvZiB0eC9yeCBwYWNrZXRz
LiBJJ3ZlIG5vdCBzZWVuIHRoYXQgd2l0aCAzLjEyIGFuZCB0aGUNCnhoY2ktcmluZy5jIHBhdGNo
Lg0KDQoJRGF2aWQNCg0KDQo=
