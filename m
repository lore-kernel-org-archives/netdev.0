From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: Fix sparse warnings with different lock
 contexts for basic block
Date: Mon, 13 Oct 2014 01:35:01 +0000
Message-ID: <b0c14b7c6f1f46d58b69c5174b3766ae@BLUPR03MB373.namprd03.prod.outlook.com>
References: <1412996429-2253-1-git-send-email-b38611@freescale.com>
 <CAOMZO5AhnRFUiCNBQ8FwdvjqVM+1fHfa3DUoHbqKTDcdg7AfBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sparse@chrisli.org" <sparse@chrisli.org>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0128.outbound.protection.outlook.com ([65.55.169.128]:19193
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752869AbaJMBfD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2014 21:35:03 -0400
In-Reply-To: <CAOMZO5AhnRFUiCNBQ8FwdvjqVM+1fHfa3DUoHbqKTDcdg7AfBA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRmFiaW8gRXN0ZXZhbSA8ZmVzdGV2YW1AZ21haWwuY29tPiBTZW50OiBTdW5kYXksIE9j
dG9iZXIgMTIsIDIwMTQgNToyMyBBTQ0KPlRvOiBEdWFuIEZ1Z2FuZy1CMzg2MTENCj5DYzogRGF2
aWQgUy4gTWlsbGVyOyBuZXRkZXZAdmdlci5rZXJuZWwub3JnOyBzcGFyc2VAY2hyaXNsaS5vcmc7
IExpIEZyYW5rLQ0KPkIyMDU5Ng0KPlN1YmplY3Q6IFJlOiBbUEFUQ0hdIG5ldDogZmVjOiBGaXgg
c3BhcnNlIHdhcm5pbmdzIHdpdGggZGlmZmVyZW50IGxvY2sNCj5jb250ZXh0cyBmb3IgYmFzaWMg
YmxvY2sNCj4NCj5IaSBGdWdhbmcsDQo+DQo+T24gU2F0LCBPY3QgMTEsIDIwMTQgYXQgMTI6MDAg
QU0sIEZ1Z2FuZyBEdWFuIDxiMzg2MTFAZnJlZXNjYWxlLmNvbT4gd3JvdGU6DQo+PiByZXByb2R1
Y2U6DQo+PiBtYWtlICBBUkNIPWFybSBDPTEgMj5mZWMudHh0IGRyaXZlcnMvbmV0L2V0aGVybmV0
L2ZyZWVzY2FsZS9mZWNfbWFpbi5vDQo+PiBjYXQgZmVjLnR4dA0KPj4NCj4+IHNwYXJzZSB3YXJu
aW5nczoNCj4+IGRyaXZlcnMvbmV0L2V0aGVybmV0L2ZyZWVzY2FsZS9mZWNfbWFpbi5jOjI5MTY6
MTI6IHdhcm5pbmc6IGNvbnRleHQNCj4+IGltYmFsYW5jZSBpbiAnZmVjX3NldF9mZWF0dXJlcycg
LSBkaWZmZXJlbnQgbG9jayBjb250ZXh0cyBmb3IgYmFzaWMNCj4+IGJsb2NrDQo+Pg0KPj4gQ2hy
aXN0b3BoZXIgTGkgc3VnZ2VzdCB0byBjaGFuZ2UgYXMgYmVsb3c6DQo+PiAgICAgICAgIGlmIChu
ZWVkX2xvY2spIHsNCj4+ICAgICAgICAgICAgICAgICBsb2NrKCk7DQo+PiAgICAgICAgICAgICAg
ICAgZG9fc29tZXRoaW5nX3JlYWwoKTsNCj4+ICAgICAgICAgICAgICAgICB1bmxvY2soKTsNCj4+
ICAgICAgICAgfSBlbHNlIHsNCj4+ICAgICAgICAgICAgICAgICBkb19zb21ldGhpbmdfcmVhbCgp
Ow0KPj4gICAgICAgICB9DQo+Pg0KPj4gUmVwb3J0ZWQtYnk6IEZhYmlvIEVzdGV2YW0gPGZlc3Rl
dmFtQGdtYWlsLmNvbT4NCj4+IFNpZ25lZC1vZmYtYnk6IEZ1Z2FuZyBEdWFuIDxCMzg2MTFAZnJl
ZXNjYWxlLmNvbT4NCj4+IFNpZ25lZC1vZmYtYnk6IENocmlzdG9waGVyIExpIDxzcGFyc2VAY2hy
aXNsaS5vcmc+DQo+DQo+SXQgbG9va3MgbGlrZSBTdWdnZXN0ZWQtYnkgaXMgYSBtb3JlIGFwcHJv
cHJpYXRlIHRhZyBmb3IgQ2hyaXN0b3BoZXIuDQoNCkFncmVlLCB0aGFua3MuIEkgd2lsbCBjaGFu
Z2UgaXQgZm9yIFYyLg0KDQpSZWdhcmRzLA0KQW5keQ0K
