From: Ilan Tayari <ilant@mellanox.com>
Subject: RE: [PATCH] gso: Validate assumption of frag_list segementation
Date: Wed, 19 Apr 2017 11:17:22 +0000
Message-ID: <AM4PR0501MB1940128F2938037CC0D04065DB180@AM4PR0501MB1940.eurprd05.prod.outlook.com>
References: <20170416080007.15990-1-ilant@mellanox.com>
 <20170417.153259.1519976990479511796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "alexander.h.duyck@intel.com" <alexander.h.duyck@intel.com>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0060.outbound.protection.outlook.com ([104.47.0.60]:62796
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933989AbdDSLR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 07:17:26 -0400
In-Reply-To: <20170417.153259.1519976990479511796.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBEYXZpZCBNaWxsZXIgW21haWx0
bzpkYXZlbUBkYXZlbWxvZnQubmV0XQ0KPiANCj4gPiBGcm9tOiBJbGFuIFRheWFyaSA8aWxhbnRA
bWVsbGFub3guY29tPg0KPiA+DQo+ID4gQ29tbWl0IDA3YjI2Yzk0NTRhMiAoImdzbzogU3VwcG9y
dCBwYXJ0aWFsIHNwbGl0dGluZyBhdCB0aGUgZnJhZ19saXN0DQo+ID4gcG9pbnRlciIpIGFzc3Vt
ZXMgdGhhdCBhbGwgU0tCcyBpbiBhIGZyYWdfbGlzdCAoZXhjZXB0IG1heWJlIHRoZSBsYXN0DQo+
ID4gb25lKSBjb250YWluIHRoZSBzYW1lIGFtb3VudCBvZiBHU08gcGF5bG9hZC4NCj4gPg0KPiA+
IFRoaXMgYXNzdW1wdGlvbiBpcyBub3QgYWx3YXlzIGNvcnJlY3QsIHJlc3VsdGluZyBpbiB0aGUg
Zm9sbG93aW5nDQo+ID4gd2FybmluZyBtZXNzYWdlIGluIHRoZSBsb2c6DQo+ID4gICAgIHNrYl9z
ZWdtZW50OiB0b28gbWFueSBmcmFncw0KPiA+DQo+ID4gRm9yIGV4YW1wbGUsIG1seDUgZHJpdmVy
IGluIFN0cmlkaW5nIFJRIG1vZGUgY3JlYXRlcyBzb21lIFJYIFNLQnMgd2l0aA0KPiA+IG9uZSBm
cmFnLCBhbmQgc29tZSB3aXRoIDIgZnJhZ3MuDQo+ID4gQWZ0ZXIgR1JPLCB0aGUgZnJhZ19saXN0
IFNLQnMgZW5kIHVwIGhhdmluZyBkaWZmZXJlbnQgYW1vdW50cyBvZg0KPiBwYXlsb2FkLg0KPiA+
IElmIHRoaXMgZnJhZ19saXN0IFNLQiBpcyB0aGVuIGZvcndhcmRlZCwgdGhlIGFmb3JlbWVudGlv
bmVkIGFzc3VtcHRpb24NCj4gPiBpcyB2aW9sYXRlZC4NCj4gPg0KPiA+IFZhbGlkYXRlIHRoZSBh
c3N1bXB0aW9uLCBhbmQgZmFsbCBiYWNrIHRvIHNvZnR3YXJlIEdTTyBpZiBpdCBub3QgdHJ1ZS4N
Cj4gPg0KPiA+IEZpeGVzOiAwN2IyNmM5NDU0YTIgKCJnc286IFN1cHBvcnQgcGFydGlhbCBzcGxp
dHRpbmcgYXQgdGhlIGZyYWdfbGlzdA0KPiA+IHBvaW50ZXIiKQ0KPiA+IFNpZ25lZC1vZmYtYnk6
IElsYW4gVGF5YXJpIDxpbGFudEBtZWxsYW5veC5jb20+DQo+ID4gU2lnbmVkLW9mZi1ieTogSWx5
YSBMZXNva2hpbiA8aWx5YWxAbWVsbGFub3guY29tPg0KPiA+IC0tLQ0KPiANCj4gWW91ciBjb21t
aXQgbWVzc2FnZSBtZW50aW9ucyBhIGZpeGVzIHRhZyB3aGljaCBtYWtlIHRoaXMgY2hhbmdlIHNl
ZW0NCj4gcmVsZXZhbnQgZm9yICduZXQnLCBidXQgeW91ciBwYXRjaCBkZXBlbmRzIHVwb24gdGhp
bmdzIGluICduZXQtbmV4dCcNCj4gYW5kIHRoZXJlZm9yZSBvbmx5IGFwcGxpZXMgdGhlcmUuDQo+
IA0KPiBJJ3ZlIGFkZGVkIHRoaXMgY2hhbmdlIHRvIG5ldC1uZXh0LCBidXQgSSB3YW50IGFuIGV4
cGxhbmF0aW9uIG9mIHdoeSB0aGlzDQo+IGNoYW5nZSBpcyBub3QgdGFyZ2V0dHRpbmcgJ25ldCcg
aWYgaXQgc2VlbXMgdG8gZml4IGEgcHJvYmxlbSB0aGVyZS4NCj4gDQo+IFRoYW5rcy4NCg0KU29y
cnksIG15IG1pc3Rha2UuDQoNClRoaXMgZml4IGRvZXMgYmVsb25nIHRvICduZXQnLCBidXQgdGhp
cyBwYXRjaCBuZWVkcyBhIG1vZGlmaWNhdGlvbiB0byBiZQ0KYXBwbGllZCB0aGVyZS4NCg0KSSB3
aWxsIHNlbmQgYSBwYXRjaCBmb3IgJ25ldCcgYXMgd2VsbC4NCg0KVGhhbmtzDQo=
