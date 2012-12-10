From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: [PATCH v4 1/5] net: Add support for hardware-offloaded
 encapsulation
Date: Mon, 10 Dec 2012 19:58:34 +0000
Message-ID: <504C9EFCA2D0054393414C9CB605C37F1BFC3555@SJEXCHMB06.corp.ad.broadcom.com>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
 <1354925658-24115-2-git-send-email-joseph.gasparakis@intel.com>
 <CAMAG_ee6xW4EnzPFt=_5+NL2+LuyUjxd52Xc242inYm2+Yhg7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"chrisw@sous-sol.org" <chrisw@sous-sol.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Peter P Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>
To: "saeed bishara" <saeed.bishara@gmail.com>,
	"Joseph Gasparakis" <joseph.gasparakis@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMAG_ee6xW4EnzPFt=_5+NL2+LuyUjxd52Xc242inYm2+Yhg7g@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBzYWVlZCBiaXNoYXJhIFttYWls
dG86c2FlZWQuYmlzaGFyYUBnbWFpbC5jb21dDQo+IFNlbnQ6IE1vbmRheSwgRGVjZW1iZXIgMTAs
IDIwMTIgMTI6MDQgUE0NCj4gVG86IEpvc2VwaCBHYXNwYXJha2lzDQo+IENjOiBkYXZlbUBkYXZl
bWxvZnQubmV0OyBzaGVtbWluZ2VyQHZ5YXR0YS5jb207IGNocmlzd0Bzb3VzLXNvbC5vcmc7DQo+
IGdvc3BvQHJlZGhhdC5jb207IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IGxpbnV4LWtlcm5lbEB2
Z2VyLmtlcm5lbC5vcmc7DQo+IERtaXRyeSBLcmF2a292OyBiaHV0Y2hpbmdzQHNvbGFyZmxhcmUu
Y29tOyBQZXRlciBQIFdhc2tpZXdpY3ogSnI7IEFsZXhhbmRlcg0KPiBEdXljaw0KPiBTdWJqZWN0
OiBSZTogW1BBVENIIHY0IDEvNV0gbmV0OiBBZGQgc3VwcG9ydCBmb3IgaGFyZHdhcmUtb2ZmbG9h
ZGVkDQo+IGVuY2Fwc3VsYXRpb24NCj4gDQo+ID4gK3N0YXRpYyBpbmxpbmUgc3RydWN0IGlwaGRy
ICppbm5lcl9pcF9oZHIoY29uc3Qgc3RydWN0IHNrX2J1ZmYgKnNrYikNCj4gPiArew0KPiA+ICsg
ICAgICAgcmV0dXJuIChzdHJ1Y3QgaXBoZHIgKilza2JfaW5uZXJfbmV0d29ya19oZWFkZXIoc2ti
KTsNCj4gPiArfQ0KPiANCj4gSGksDQo+IEknbSBhIGxpdHRsZSBiaXQgYm90aGVyZWQgYmVjYXVz
ZSBvZiB0aG9zZSBpbm5lcl8gZnVuY3Rpb25zLCB3aGF0DQo+IGFib3V0IHRoZSBmb2xsb3dpbmcg
YXBwcm9hY2g6DQo+IDEuIHRoZSBza2Igd2lsbCBoYXZlIGEgbmV3IHN0YXRlLCB0aGF0IHN0YXRl
IGNhbiBiZSBvdXRlciAobm9ybWFsDQo+IG1vZGUpIGFuZCBpbm5lci4NCj4gMi4gd2hlbiB5b3Ug
Y2hhbmdlIHRoZSBzdGF0ZSB0byBpbm5lciwgYWxsIHRoZSBoZWxwZXIgZnVuY3Rpb25zIHN1Y2gN
Cj4gYXMgaXBfaGRyIHdpbGwgcmV0dXJuIHRoZSBpbm50ZXIgaGVhZGVyLg0KPiANCj4gdGhhdCdz
IG9mY291cnNlIHRoZSBBUEkgc2lkZS4gdGhlIGltcGxlbWVudGF0aW9uIG1heSBzdGlsbCB1c2Ug
dGhlDQo+IGZpZWxkcyB5b3UgYWRkZWQgdG8gdGhlIHNrYi4NCj4gDQo+IHdoYXQgeW91IHRoaW5r
Pw0KPiBzYWVlZA0KDQpTb21lIGRyaXZlcnMgd2lsbCBwcm9iYWJseSBuZWVkIGJvdGggaW5uZXJf
IGFuZCBvdGhlcl8gaW4gc2FtZSBmbG93LCBzd2l0Y2hpbmcgYmV0d2VlbiB0d28gc3RhdGVzIHdp
bGwgY29uc3VtZSBjcHUgY3ljbGVzLiANCg==
