From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: RE: [PATCH v3 0/2] fjes: Do not load fjes driver
Date: Thu, 23 Mar 2017 00:02:00 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A741D2417@G01JPEXMBYT21>
References: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>
To: 'YASUAKI ISHIMATSU' <yasu.isimatu@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgwkm01.jp.fujitsu.com ([202.219.69.168]:12660 "EHLO
        mgwkm01.jp.fujitsu.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751211AbdCWADI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 20:03:08 -0400
Received: from g01jpfmpwyt03.exch.g01.fujitsu.local (g01jpfmpwyt03.exch.g01.fujitsu.local [10.128.193.57])
        by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 62B5FAC0164
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:02:03 +0900 (JST)
In-Reply-To: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VGVzdGVkLWJ5OiBUYWt1IEl6dW1pIDxpenVtaS50YWt1QGpwLmZ1aml0c3Uu
Y29tPg0KDQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206
IFlBU1VBS0kgSVNISU1BVFNVIFttYWlsdG86eWFzdS5pc2ltYXR1QGdtYWls
LmNvbV0NCj4gU2VudDogV2VkbmVzZGF5LCBNYXJjaCAyMiwgMjAxNyAxMjoy
OCBBTQ0KPiBUbzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZw0KPiBDYzogRGF2
aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PjsgSXp1bWksIFRha3Uv
5rOJIOaLkw0KPiA8aXp1bWkudGFrdUBqcC5mdWppdHN1LmNvbT47IHlhc3Uu
aXNpbWF0dUBnbWFpbC5jb20NCj4gU3ViamVjdDogW1BBVENIIHYzIDAvMl0g
ZmplczogRG8gbm90IGxvYWQgZmplcyBkcml2ZXINCj4gDQo+IFRoZSBmamVz
IGRyaXZlciBpcyB1c2VkIG9ubHkgYnkgRlVKSVRTVSBzZXJ2ZXJzIGFuZCBh
bG1vc3Qgb2YgYWxsIHNlcnZlcnMNCj4gaW4gdGhlIHdvcmxkIG5ldmVyIHVz
ZSBpdC4gQnV0IGN1cnJlbnRseSBpZiBBQ1BJIFBOUDBDMDIgaXMgZGVmaW5l
ZCBpbiB0aGUNCj4gQUNQSSB0YWJsZSwgdGhlIGZvbGxvd2luZyBtZXNzYWdl
IGlzIGFsd2F5cyBzaG93bjoNCj4gDQo+ICAiRlVKSVRTVSBFeHRlbmRlZCBT
b2NrZXQgTmV0d29yayBEZXZpY2UgRHJpdmVyIC0gdmVyc2lvbiAxLjINCj4g
ICAtIENvcHlyaWdodCAoYykgMjAxNSBGVUpJVFNVIExJTUlURUQiDQo+IA0K
PiBUaGUgbWVzc2FnZSBtYWtlcyB1c2VycyBjb25mdXNlZCBiZWNhdXNlIHRo
ZXJlIGlzIG5vIHJlYXNvbiB0aGF0IHRoZSBtZXNzYWdlDQo+IGlzIHNob3du
IGluIG90aGVyIHZlbmRvciBzZXJ2ZXJzLg0KPiANCj4gVG8gYXZvaWQgdGhl
IGNvbmZ1c2lvbiwgdGhlIHBhdGNoIGFkZHMgc2V2ZXJhbCBjaGVja3MuDQo+
IA0KPiB2MzoNCj4gICAtIFJlYmFzZSBvbiBsYXRlc3QgbmV0IHRyZWUuDQo+
ICAgLSBBZGQgX1NUQSBtZXRob2QgY2hlY2sgdG8gYXZvaWQgbG9hZGluZyBm
amVzIGRyaXZlci4NCj4gDQo+IHYyOg0KPiAgIC0gT3JkZXIgbG9jYWwgdmFy
aWFibGUgZGVjbGFyYXRpb25zIGZyb20gbG9uZ2VzdCB0byBzaG9ydGVzdCBs
aW5lDQo+IA0KPiBZYXN1YWtpIElzaGltYXRzdSgyKToNCj4gICBmamVzOiBE
byBub3QgbG9hZCBmamVzIGRyaXZlciBpZiBzeXN0ZW0gZG9lcyBub3QgaGF2
ZSBleHRlbmRlZCBzb2NrZXQNCj4gZGV2aWNlLg0KPiAgIGZqZXM6IERvIG5v
dCBsb2FkIGZqZXMgZHJpdmVyIGlmIGV4dGVuZGVkIHNvY2tldCBkZXZpY2Ug
aXMgbm90IHBvd2VyIG9uLg0KPiANCj4gIGRyaXZlcnMvbmV0L2ZqZXMvZmpl
c19tYWluLmMgfCA3Ng0KPiArKysrKysrKysrKysrKysrKysrKysrKysrKysr
KysrKysrKysrKysrKy0tLQ0KPiAgMSBmaWxlIGNoYW5nZWQsIDcxIGluc2Vy
dGlvbnMoKyksIDUgZGVsZXRpb25zKC0pDQoNCg==
