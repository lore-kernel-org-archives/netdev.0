From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 09/11] net: mvpp2: simplify MVPP2_PRS_RI_* definitions
Date: Wed, 4 Jan 2017 10:14:04 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02555FB@AcuExch.aculab.com>
References: <1482857660-16092-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1482857660-16092-10-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Nadav Haklai <nadavh@marvell.com>, Hanna Hawa <hannah@marvell.com>,
        "Yehuda Yitschak" <yehuday@marvell.com>,
        Jason Cooper <jason@lakedaemon.net>,
        "Andrew Lunn" <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        Stefan Chulski <stefanc@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>
To: 'Thomas Petazzoni' <thomas.petazzoni@free-electrons.com>,
        "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.183]:54198 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752163AbdADKOf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 05:14:35 -0500
In-Reply-To: <1482857660-16092-10-git-send-email-thomas.petazzoni@free-electrons.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVGhvbWFzIFBldGF6em9uaQ0KPiBTZW50OiAyNyBEZWNlbWJlciAyMDE2IDE2OjU0DQo+
IFNvbWUgb2YgdGhlIE1WUFAyX1BSU19SSV8qIGRlZmluaXRpb25zIHVzZSB0aGUgfih2YWx1ZSkg
c3ludGF4LCB3aGljaA0KPiBkb2Vzbid0IGNvbXBpbGUgbmljZWx5IG9uIDY0LWJpdC4gTW9yZW92
ZXIsIHRob3NlIGRlZmluaXRpb25zIGFyZSBpbg0KPiBmYWN0IHVubmVlZGVkLCBzaW5jZSB0aGV5
IGFyZSBhbHdheXMgdXNlZCBpbiBjb21iaW5hdGlvbiB3aXRoIGEgYml0DQo+IG1hc2sgdGhhdCBl
bnN1cmVzIG9ubHkgdGhlIGFwcHJvcHJpYXRlIGJpdHMgYXJlIG1vZGlmaWVkLg0KPiANCj4gVGhl
cmVmb3JlLCBzdWNoIGRlZmluaXRpb25zIHNob3VsZCBqdXN0IGJlIHNldCB0byAweDAuIEZvciBl
eGFtcGxlOg0KPiANCj4gICNkZWZpbmUgTVZQUDJfUFJTX1JJX0wyX0NBU1RfTUFTSyAgICAgICAg
ICAgICAgMHg2MDANCj4gICNkZWZpbmUgTVZQUDJfUFJTX1JJX0wyX1VDQVNUICAgICAgICAgICAg
ICAgICAgfihCSVQoOSkgfCBCSVQoMTApKQ0KPiAgI2RlZmluZSBNVlBQMl9QUlNfUklfTDJfTUNB
U1QgICAgICAgICAgICAgICAgICBCSVQoOSkNCj4gICNkZWZpbmUgTVZQUDJfUFJTX1JJX0wyX0JD
QVNUICAgICAgICAgICAgICAgICAgQklUKDEwKQ0KPiANCj4gYmVjb21lcw0KPiANCj4gICNkZWZp
bmUgTVZQUDJfUFJTX1JJX0wyX0NBU1RfTUFTSyAgICAgICAgICAgICAgMHg2MDANCj4gICNkZWZp
bmUgTVZQUDJfUFJTX1JJX0wyX1VDQVNUICAgICAgICAgICAgICAgICAgMHgwDQo+ICAjZGVmaW5l
IE1WUFAyX1BSU19SSV9MMl9NQ0FTVCAgICAgICAgICAgICAgICAgIEJJVCg5KQ0KPiAgI2RlZmlu
ZSBNVlBQMl9QUlNfUklfTDJfQkNBU1QgICAgICAgICAgICAgICAgICBCSVQoMTApDQouLi4NClNo
b3VsZG4ndCBNVlBQMl9QUlNfUklfTDJfQ0FTVF9NQVNLIGJlIGRlZmluZWQgYXMNCihNVlBQMl9Q
UlNfUklfTDJfTUNBU1QgfCBNVlBQMl9QUlNfUklfTDJfQkNBU1QpPw0KDQoJRGF2aWQNCg0KDQo=
