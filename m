From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: RE: [PATCH] net: phylib: fix interrupts re-enablement in phy_start
Date: Wed, 11 May 2016 02:15:13 +0000
Message-ID: <DB5PR0401MB2183495D42037728D1738301E8720@DB5PR0401MB2183.eurprd04.prod.outlook.com>
References: <1462873346-46457-1-git-send-email-shh.xie@gmail.com>
 <57322792.4060008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0073.outbound.protection.outlook.com ([157.56.112.73]:3721
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751340AbcEKDtF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 23:49:05 -0400
In-Reply-To: <57322792.4060008@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBGbG9yaWFuIEZhaW5lbGxpIFtt
YWlsdG86Zi5mYWluZWxsaUBnbWFpbC5jb21dDQo+IFNlbnQ6IFdlZG5lc2RheSwgTWF5IDExLCAy
MDE2IDI6MjUgQU0NCj4gVG86IHNoaC54aWVAZ21haWwuY29tOyBuZXRkZXZAdmdlci5rZXJuZWwu
b3JnOyBkYXZlbUBkYXZlbWxvZnQubmV0DQo+IENjOiBTaGFvaHVpIFhpZSA8c2hhb2h1aS54aWVA
bnhwLmNvbT47IEFuZHJldyBMdW5uIDxhbmRyZXdAbHVubi5jaD4NCj4gU3ViamVjdDogUmU6IFtQ
QVRDSF0gbmV0OiBwaHlsaWI6IGZpeCBpbnRlcnJ1cHRzIHJlLWVuYWJsZW1lbnQgaW4gcGh5X3N0
YXJ0DQo+IA0KPiBPbiAwNS8xMC8yMDE2IDAyOjQyIEFNLCBzaGgueGllQGdtYWlsLmNvbSB3cm90
ZToNCj4gPiBGcm9tOiBTaGFvaHVpIFhpZSA8U2hhb2h1aS5YaWVAbnhwLmNvbT4NCj4gPg0KPiA+
IElmIHBoeSB3YXMgc3VzcGVuZGVkIGFuZCBpcyBzdGFydGluZywgY3VycmVudCBkcml2ZXIgYWx3
YXlzIGVuYWJsZQ0KPiA+IHBoeSdzIGludGVycnVwdHMsIGlmIHBoeSB3b3JrcyBpbiBwb2xsaW5n
LCBwaHkgY2FuIHJhaXNlIHVuZXhwZWN0ZWQNCj4gPiBpbnRlcnJ1cHQgd2hpY2ggd2lsbCBub3Qg
YmUgaGFuZGxlZCwgdGhlIGludGVycnVwdCB3aWxsIGJsb2NrIHN5c3RlbQ0KPiA+IGVudGVyIHN1
c3BlbmQgYWdhaW4uIFNvIGludGVycnVwdHMgc2hvdWxkIG9ubHkgYmUgcmUtZW5hYmxlZCBpZiBw
aHkNCj4gPiB3b3JrcyBpbiBpbnRlcnJ1cHQuDQo+IA0KPiBZb3VyIGV4cGxhbmF0aW9uIG1ha2Vz
IHNlbnNlLiBUaGUgY29tbWl0IG1lc3NhZ2UgY291bGQgeW91IHVzZSBzb21lDQo+IGltcHJvdmVt
ZW50cyBsaWtlIHMvcGh5L1BIWS8gYW5kICJ3b3JrcyBpbiBpbnRlcnJ1cHQgbW9kZSIsIGJ1dCB0
aGF0IGlzIG5vdCBhDQo+IGh1Z2UgdGhpbmcuDQpbUy5IXSBUaGFuayB5b3UgZm9yIHRoZSBjb21t
ZW50Lg0KDQpJIHNob3VsZCBtYWtlIHRoZSBjb21taXQgbWVzc2FnZSBtb3JlIHByZWNpc2UgYW5k
IHdpbGwgbWFrZSBpbXByb3ZlbWVudCBpbg0KZnV0dXJlIHBhdGNoIHN1Ym1pc3Npb24uDQoNClJl
Z2FyZHMsDQpTaGFvaHVpDQo=
