From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net 1/1] net: fec: fix multicast filtering hardware setup
Date: Mon, 13 Feb 2017 01:51:03 +0000
Message-ID: <AM4PR0401MB22605026E93B76BE751E487DFF590@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <1486706069-29124-1-git-send-email-fugang.duan@nxp.com>
 <CAOMZO5A=JQHDU6qFqzzkKQWStUqhDngRcbuf-qmSWgZUd7VRyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0055.outbound.protection.outlook.com ([104.47.0.55]:56096
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751302AbdBMBvG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 12 Feb 2017 20:51:06 -0500
In-Reply-To: <CAOMZO5A=JQHDU6qFqzzkKQWStUqhDngRcbuf-qmSWgZUd7VRyA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRmFiaW8gRXN0ZXZhbSA8ZmVzdGV2YW1AZ21haWwuY29tPiBTZW50OiBTYXR1cmRheSwg
RmVicnVhcnkgMTEsIDIwMTcgNToyMCBBTQ0KPlRvOiBBbmR5IER1YW4gPGZ1Z2FuZy5kdWFuQG54
cC5jb20+DQo+Q2M6IERhdmlkIFMuIE1pbGxlciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD47IG5ldGRl
dkB2Z2VyLmtlcm5lbC5vcmc7DQo+U3RlcGhlbiBIZW1taW5nZXIgPHN0ZXBoZW5AbmV0d29ya3Bs
dW1iZXIub3JnPg0KPlN1YmplY3Q6IFJlOiBbUEFUQ0ggbmV0IDEvMV0gbmV0OiBmZWM6IGZpeCBt
dWx0aWNhc3QgZmlsdGVyaW5nIGhhcmR3YXJlIHNldHVwDQo+DQo+T24gRnJpLCBGZWIgMTAsIDIw
MTcgYXQgMzo1NCBBTSwgQW5keSBEdWFuIDxmdWdhbmcuZHVhbkBueHAuY29tPiB3cm90ZToNCj4+
IEZpeCBoYXJkd2FyZSBzZXR1cCBvZiBtdWx0aWNhc3QgYWRkcmVzcyBoYXNoOg0KPj4gLSBOZXZl
ciBjbGVhciB0aGUgaGFyZHdhcmUgaGFzaCAodG8gYXZvaWQgcGFja2V0IGxvc3MpDQo+PiAtIENv
bnN0cnVjdCB0aGUgaGFzaCByZWdpc3RlciB2YWx1ZXMgaW4gc29mdHdhcmUgYW5kIHRoZW4gd3Jp
dGUgb25jZQ0KPj4gdG8gaGFyZHdhcmUNCj4+DQo+PiBTaWduZWQtb2ZmLWJ5OiBGdWdhbmcgRHVh
biA8ZnVnYW5nLmR1YW5AbnhwLmNvbT4NCj4+IFNpZ25lZC1vZmYtYnk6IFJ1aSBTb3VzYSA8cnVp
LnNvdXNhQG54cC5jb20+DQo+DQo+SXQgc2VlbXMgeW91IG1pc3NlZCB0byBwdXQgUnVpJ3MgbmFt
ZSBpbiB0aGUgRnJvbTogZmllbGQuDQoNCkkgZGlkIHNvbWUgY2hhbmdlIGJhc2Ugb24gb3JpZ2lu
YWwgcGF0Y2ggYW5kIG1lcmdlIGludG8gbmV0IHRyZWUuDQpGb3JnZXQgdG8gY2hhbmdlIHRociBG
UiBmaWVsZCwgc2VuZCBpdCBhZ2Fpbiwgbm90IFYyIHZlcnNpb24uDQoNClJlZ2FyZHMsDQpBbmR5
DQo=
