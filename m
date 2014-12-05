From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [patch net-next v2 1/2] rocker: introduce be put/get variants
 and use it when appropriate
Date: Fri, 5 Dec 2014 09:57:43 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CA033CC@AcuExch.aculab.com>
References: <1417612494-3788-1-git-send-email-jiri@resnulli.us>
 <CAE4R7bAgSji_rt3147Kt8jqyT5_yqBCbKjSLgZVa8xkRc0dndA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: 'Scott Feldman' <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45609 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753289AbaLEJ61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2014 04:58:27 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07098-03 for <netdev@vger.kernel.org>;
 Fri,  5 Dec 2014 09:58:18 +0000 (GMT)
In-Reply-To: <CAE4R7bAgSji_rt3147Kt8jqyT5_yqBCbKjSLgZVa8xkRc0dndA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU2NvdHQgRmVsZG1hbg0KPiBTaWduZWQtb2ZmLWJ5OiBTY290dCBGZWxkbWFuIDxzZmVs
ZG1hQGdtYWlsLmNvbT4NCj4gDQo+IE9uIFdlZCwgRGVjIDMsIDIwMTQgYXQgNToxNCBBTSwgSmly
aSBQaXJrbyA8amlyaUByZXNudWxsaS51cz4gd3JvdGU6DQo+ID4gVGhpcyBraWxscyB0aGUgc3Bh
cnNlIHdhcm5pbmdzLg0KPiA+DQo+ID4gU2lnbmVkLW9mZi1ieTogSmlyaSBQaXJrbyA8amlyaUBy
ZXNudWxsaS51cz4NCj4gPiAtLS0NCj4gPiB2MS0+djI6DQo+ID4gLW5vIGNoYW5nZQ0KPiA+IC0t
LQ0KPiA+ICBkcml2ZXJzL25ldC9ldGhlcm5ldC9yb2NrZXIvcm9ja2VyLmMgfCA3OSArKysrKysr
KysrKysrKysrKysrKysrLS0tLS0tLS0tLS0tLS0NCj4gPiAgMSBmaWxlIGNoYW5nZWQsIDQ4IGlu
c2VydGlvbnMoKyksIDMxIGRlbGV0aW9ucygtKQ0KPiA+DQo+ID4gZGlmZiAtLWdpdCBhL2RyaXZl
cnMvbmV0L2V0aGVybmV0L3JvY2tlci9yb2NrZXIuYyBiL2RyaXZlcnMvbmV0L2V0aGVybmV0L3Jv
Y2tlci9yb2NrZXIuYw0KPiA+IGluZGV4IGZkZWQxMjcuLjRiMDYwZmIgMTAwNjQ0DQo+ID4gLS0t
IGEvZHJpdmVycy9uZXQvZXRoZXJuZXQvcm9ja2VyL3JvY2tlci5jDQo+ID4gKysrIGIvZHJpdmVy
cy9uZXQvZXRoZXJuZXQvcm9ja2VyL3JvY2tlci5jDQo+ID4gQEAgLTY0OCw2ICs2NDgsMTEgQEAg
c3RhdGljIHUxNiByb2NrZXJfdGx2X2dldF91MTYoY29uc3Qgc3RydWN0IHJvY2tlcl90bHYgKnRs
dikNCj4gPiAgICAgICAgIHJldHVybiAqKHUxNiAqKSByb2NrZXJfdGx2X2RhdGEodGx2KTsNCj4g
PiAgfQ0KPiA+DQo+ID4gK3N0YXRpYyBfX2JlMTYgcm9ja2VyX3Rsdl9nZXRfYmUxNihjb25zdCBz
dHJ1Y3Qgcm9ja2VyX3RsdiAqdGx2KQ0KPiA+ICt7DQo+ID4gKyAgICAgICByZXR1cm4gKihfX2Jl
MTYgKikgcm9ja2VyX3Rsdl9kYXRhKHRsdik7DQo+ID4gK30NCg0KKihpbnRfdHlwZSAqKWZvbyBh
bHdheXMgcmluZ3MgYWxhcm0gYmVsbHMuLi4uLg0KDQpUaGF0IGxvb2tzIGR1YmlvdXMgb24gc3lz
dGVtcyB3aGVyZSBtaXNhbGlnbmVkIHRyYW5zZmVycyBmYXVsdC4NCg0KCURhdmlkDQoNCg==
