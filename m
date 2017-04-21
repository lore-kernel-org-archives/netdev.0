From: Andy Duan <fugang.duan@nxp.com>
Subject: Re: FEC on i.MX 7 transmit queue timeout
Date: Fri, 21 Apr 2017 02:48:31 +0000
Message-ID: <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
References: <c6b66956c48f981a952048da6b2ddd54@agner.ch>
 <ed24e51d-499f-597b-0c9f-7f180e257acb@nxp.com>
 <e99d7c93b7819507c6448842015bf836@agner.ch>
 <AM4PR0401MB2260EBCD552219D3402B68FEFF180@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <86b63ee28acfff3426c4a0bf72d848c1@agner.ch>
 <2bdd64ab-5644-e0a0-9bfe-b8dd2fca7abb@nxp.com>
 <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "fugang.duan@freescale.com" <fugang.duan@freescale.com>,
        "festevam@gmail.com" <festevam@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Stefan Agner <stefan@agner.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0072.outbound.protection.outlook.com ([104.47.0.72]:30944
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1034866AbdDUCsf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 22:48:35 -0400
In-Reply-To: <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
Content-Language: en-US
Content-ID: <412F54F769F7424CBA30DDC5C65775E6@eurprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQpPbiAyMDE35bm0MDTmnIgyMOaXpSAwNzoxNSwgU3RlZmFuIEFnbmVyIHdyb3RlOg0KPiBJIHRl
c3RlZCBhZ2FpbiB3aXRoIGlteDZzeC1mZWMgY29tcGF0aWJsZSBzdHJpbmcuIEkgY291bGQgcmVw
cm9kdWNlIGl0DQo+IG9uIGEgQ29saWJyaSB3aXRoIGkuTVggN0R1YWwuIEJ1dCBub3QgYWx3YXlz
OiBJdCByZWFsbHkgZGVwZW5kcyB3aGV0aGVyDQo+IHF1ZXVlIDIgaXMgY291bnRpbmcgdXAgb3Ig
bm90LiBKdXN0IGFmdGVyIGJvb3QsIEkgY2hlY2sgL3Byb2MvaW50ZXJydXB0cw0KPiB0d2ljZSwg
aWYgcXVldWUgMiBpcyBjb3VudGluZyBpdCB3aWxsIGhhcHBlbiENCj4NCj4gQnV0IGlmIG9ubHkg
cXVldWUgMCBpcyBtb3N0bHkgaW4gdXNlLCB0aGVuIGl0IHNlZW1zIHRvIHdvcmsganVzdCBmaW5l
Lg0KSWYgeW91ciBjYXNlIGlzIG9ubHkgcnVubmluZyBiZXN0IGVmZm9ydCBsaWtlIHRjcC91ZHAs
IHlvdSBjYW4gcmUtc2V0IA0KdGhlICJmc2wsbnVtLXR4LXF1ZXVlcyIgYW5kICJmc2wsbnVtLXJ4
LXF1ZXVlcyIgdG8gMSBpbiBib2FyZCBkdHMgZmlsZS4NCk90aGVyIHR3byBxdWV1ZXMgYXJlIGZv
ciBBVkIgYXVkaW8vdmlkZW8gcXVldWVzLCB0aGV5IGhhdmUgaGlnaCBwcmlvcml0eSANCnRoYW4g
cXVldWUgMC4gSWYgcnVubmluZyBpcGVyZiB0Y3AgdGVzdCBvbiB0aGUgdGhyZWUgcXVldWVzLCB0
aGVuDQp0aGUgdGNwIHNlZ21lbnQgbWF5IGJlIG91dC1vZi1vcmRlciB0aGF0IGNhdXNlIG5ldCB3
YXRjaGRvZyB0aW1lb3V0Lg0KPg0KPiBJIGFsc28gdHJpZWQgaS5NWCA3RHVhbCBTYWJyZVNEIGhl
cmUsIGFuZCB0aGUgc2FtZSB0aGluZy4gSSBoYWQgdG8NCj4gcmVib290IDMgdGltZXMsIHRoZW4g
cXVldWUgMiB3YXMgY291bnRpbmc6DQo+ICAgNTc6ICAgICAgICAgIDggICAgIEdJQy0wIDE1MCBM
ZXZlbCAgICAgMzBiZTAwMDAuZXRoZXJuZXQNCj4gICA1ODogICAgICAyMDEzNyAgICAgR0lDLTAg
MTUxIExldmVsICAgICAzMGJlMDAwMC5ldGhlcm5ldA0KPiAgIDU5OiAgICAgICA5MjY5ICAgICBH
SUMtMCAxNTIgTGV2ZWwgICAgIDMwYmUwMDAwLmV0aGVybmV0DQo+DQo+IEl0IHRvb2sgbWUgYWJv
dXQgNDAgbWludXRlcyBvbiBTYWJyZSB1bnRpbCBpdCBoYXBwZW5lZCwgYW5kIEkgaGFkIHRvDQo+
IGZvcmNlIGl0IHVzaW5nIGlwZXJmLCBidXQgdGhlbiBJIGdvdCB0aGUgcmluZyBkdW1wczoNCk15
IGJvYXJkIGhhZCByYW4gbW9yZSB0aGFuIDQ3IGhvdXJzIHdpdGggbmZzIHJvb3RmcyBpbiA0LjEx
LjAtcmM2LCBidXQgDQpub3QgcnVubmluZyBpcGVyZi4NCkkgYW0gdGVzdGluZyB3aXRoIGlwZXJm
Lg0KDQpBbmR5
