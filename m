From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: SCTP MSG_MORE code
Date: Thu, 23 Mar 2017 16:11:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFFB6448@AcuExch.aculab.com>
References: <063D6719AE5E284EB5DD2968C1650D6DCFFB5839@AcuExch.aculab.com>
 <CADvbK_ffK4Cw6FmwDUw-hDJBANqWpxrCMMzFQ5ikb7jD_tSdkQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Xin Long' <lucien.xin@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.181]:55162 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965354AbdCWQLW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 12:11:22 -0400
In-Reply-To: <CADvbK_ffK4Cw6FmwDUw-hDJBANqWpxrCMMzFQ5ikb7jD_tSdkQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogWGluIExvbmcNCj4gU2VudDogMjEgTWFyY2ggMjAxNyAwNjowMQ0KPiBPbiBUdWUsIE1h
ciAyMSwgMjAxNyBhdCAxOjQ5IEFNLCBEYXZpZCBMYWlnaHQgPERhdmlkLkxhaWdodEBhY3VsYWIu
Y29tPiB3cm90ZToNCj4gPiBTb21ldGhpbmcgbmVlZHMgdG8gYmUgZG9uZSB3aXRoIFNDVFAgTVNH
X01PUkUgYmVmb3JlIHRoZSBlbmQgb2YgdGhlIHJjIGN5Y2xlLg0KPiA+IFRoZSBjdXJyZW50IGNv
ZGUgaXMgZGVmaW5pdGVseSBicm9rZW4uDQo+IGFncmVlZC4NCj4gDQo+ID4NCj4gPiBJIG9iamVj
dGVkIHRvIHRoZSBsYXN0ICdmaXgnIHBhdGNoIGJlY2F1c2UgaXQgY2xlYXJzIHRoZSBmbGFnIGlz
IGEgcGxhY2Ugd2hlcmUNCj4gPiBJIGRvbid0IHRoaW5rIGl0IGlzIG5lY2Vzc2FyeSB0byBkbyBz
byAtIHNvIGNvdWxkIGdlbmVyYXRlIGV4dHJhIGV0aGVybmV0IGZyYW1lcy4NCj4gPg0KPiBTb3Jy
eSwgY2FuIHlvdSBkb3VibGUgY2hlY2sgdGhlIGxhc3QgJ2ZpeCcgcGF0Y2ggPw0KPiBJIGNvdWxk
IG5vdCBnZXQgJ2dlbmVyYXRlIGV4dHJhIGV0aGVybmV0IGZyYW1lcycuDQoNCkl0IHdvdWxkIHJl
cXVpcmUgdGhlIGNvbm5lY3Rpb24gYmUgJ2Zsb3cgY29udHJvbGxlZCcgYW5kL29yIGhhdmUNCnJl
dHJhbnNtaXNzaW9ucy4NCk90aGVyd2lzZSAnZGF0YSBjaHVuayBvbmx5JyBldGhlcm5ldCBmcmFt
ZXMgYXJlIG9ubHkgZ2VuZXJhdGVkIGluIHJlc3BvbnNlDQp0byBzZW5kKCkgc28gd291bGQgYWx3
YXlzIHNlZSB0aGUgdmFsdWUgZnJvbSB0aGUgbGFzdCBzZW5kKCkuDQoNCj4gaWYgd2Uga2VlcCBz
ZW5kaW5nIGRhdGEgd2l0aCAiTVNHX01PUkUiLCBhZnRlciBvbmUgZXRoZXJuZXQgZnJhbWUNCj4g
aXMgc2VudCwgImZvbGxvd2VkIGJ5IGEgc2Vjb25kIGV0aGVybmV0IGZyYW1lIHdpdGggMSBjaHVu
ayBpbiBpdCIgd2lsbCBOT1QNCj4gaGFwcGVuLCBhcyBpbiB0aGlzIGxvb3AgdGhlIGFzb2MncyBt
c2dfbW9yZSBmbGFnIGlzIHN0aWxsIHNldCwgYW5kIHRoaXMgZmx1c2gNCj4gaXMgY2FsbGVkIGJ5
IHNjdHBfc2VuZG1zZyh0aGUgZnVuY3Rpb24gbXNnX21vcmUgc2hvdWxkIGNhcmUgbW9yZSkuDQo+
IA0KPiANCj4gSWYgeW91ciBwb2ludCBhYm91dCAiZ2VuZXJhdGUgZXh0cmEgZXRoZXJuZXQgZnJh
bWVzIiAgaXMgcmlnaHQsIHN1cmUsIEkgd2lsbA0KPiBjaGFuZ2UgdGhlIHdheSB0byBmaXggdGhh
dC4gYnV0IGJlZm9yZSB0aGlzLCBwbHMgY2hlY2sgaXQgYWdhaW4sIGFwcHJlY2lhdGUgaXQuDQoN
Ckkgd29uJ3QgYmUgYWJsZSB0byB0ZXN0IHRoaXMgaW4gdGhlIHNob3J0IHRlcm0uDQoNCglEYXZp
ZA0KDQo=
