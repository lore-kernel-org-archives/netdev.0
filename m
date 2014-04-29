From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 5/7] net:fec: add support for dumping transmit
 ring on timeout
Date: Tue, 29 Apr 2014 14:23:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F70156E@AcuExch.aculab.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
	<1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F7014F0@AcuExch.aculab.com>
	<CAHrpEqSCSw=bYgx5Egk4Mva-CODnw5=vvK6y3VWmB3_QpBQ8sQ@mail.gmail.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F701524@AcuExch.aculab.com>
 <CAHrpEqRZ1oyd6bXXqxznfw+1qwo5LVBW10mcrzLbbCHYowPetA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Frank Li <Frank.Li@freescale.com>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"B38611@freescale.com" <B38611@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Frank Li' <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:51416 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932284AbaD2OZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 10:25:04 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 03148-08 for <netdev@vger.kernel.org>;
 Tue, 29 Apr 2014 15:25:02 +0100 (BST)
In-Reply-To: <CAHrpEqRZ1oyd6bXXqxznfw+1qwo5LVBW10mcrzLbbCHYowPetA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRnJhbmsgTGkgW21haWx0bzpsem51YWFAZ21haWwuY29tXQ0KPiBPbiBUdWUsIEFwciAy
OSwgMjAxNCBhdCA5OjAxIEFNLCBEYXZpZCBMYWlnaHQgPERhdmlkLkxhaWdodEBhY3VsYWIuY29t
PiB3cm90ZToNCj4gPiBGcm9tOiBGcmFuayAuLi4NCj4gPj4gPiBZb3UgcHJvYmFibHkgd2FudCB0
aGUgcmVhZCBhbmQgd3JpdGUgaW5kZXhlcyBhcyB3ZWxsLg0KPiA+Pg0KPiA+PiAgICAgICAgICAg
ICAgICAgICAgICBiZHAgPT0gZmVwLT5jdXJfdHggPyAnUycgOiAnICcsDQo+ID4+ICAgICAgICAg
ICAgICAgICAgICAgIGJkcCA9PSBmZXAtPmRpcnR5X3R4ID8gJ0gnIDogJyAnLA0KPiA+Pg0KPiA+
PiBBYm92ZSBjb2RlIGFscmVhZHkgcHJpbnQgcmVhZCBhbmQgd3JpdGUgaW5kZXguICdTJywgJ0gn
DQo+ID4NCj4gPiBHYWggSSBtdXN0IGJlIGFzbGVlcCENCj4gPiBTb21ldGhpbmcgbWFkZSBiZSB0
aGluayB0aGF0IHdhcyB0byBkbyB3aXRoIHRoZSByaW5nIG93bmVyc2hpcCBiaXQhDQo+IA0KPiBJ
IHRoaW5rIGl0IGlzIHNhbWUgdGhpbmcuIElmIEkgYW0gd3JvbmcsIHBsZWFzZSB0ZWxsIG1lIGRp
ZmZlcmVuY2UuDQoNClRoZSBvd25lcnNoaXAgYml0IGluIHRoZSByaW5nIGZsYWdzIC0gdGhhdCB0
aGUgaGFyZHdhcmUgdXNlcy4NCldoaWNoIGFyZSBwcmludGVkIGluIHRoZSBuZXh0IGZpZWxkLg0K
DQpJJ20gZ3Vlc3NpbmcgdGhhdCB0aGUgcmVhc29uIHRoZSB0eCByaW5nIGlzICdpbnRlcmVzdGlu
ZycgaXMgdGhhdCB0aGVyZQ0KaGF2ZSBiZWVuIGJ1Z3Mgd2hlcmUgdGhlIGRyaXZlciBhbmQgaGFy
ZHdhcmUgZGlzYWdyZWUgYWJvdXQgd2hpY2ggZW50cnkNCmVhY2ggc2hvdWxkIHByb2Nlc3MgbmV4
dC4NCk90aGVyd2lzZSB0aGUgZnVsbCB0eCByaW5nIGlzIGxpa2VseSB0byBiZSB2ZXJ5IHZlcnkg
Ym9yaW5nLg0KDQoJRGF2aWQNCg0K
