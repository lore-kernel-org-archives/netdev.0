From: Rafal Ozieblo <rafalo@cadence.com>
Subject: RE: [RFC PATCH net-next v4 1/2] macb: Add 1588 support in Cadence
 GEM.
Date: Tue, 3 Jan 2017 10:47:56 +0000
Message-ID: <BN3PR07MB25168573DD82F1681CDC8437C96E0@BN3PR07MB2516.namprd07.prod.outlook.com>
References: <1481720175-12703-1-git-send-email-andrei.pistirica@microchip.com>
 <BN3PR07MB2516815EDE69ACDCE27F81A3C96F0@BN3PR07MB2516.namprd07.prod.outlook.com>
 <20170102113155.GA16373@localhost.localdomain>
 <0717c63b-2e29-9ad1-7f01-39817980933f@atmel.com>
 <20170102161359.GD3609@localhost.localdomain>
 <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
        Andrei Pistirica <andrei.pistirica@microchip.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "harini.katakam@xilinx.com" <harini.katakam@xilinx.com>,
        "punnaia@xilinx.com" <punnaia@xilinx.com>,
        "michals@xilinx.com" <michals@xilinx.com>,
        "anirudh@xilinx.com" <anirudh@xilinx.com>,
        "boris.brezillon@free-electrons.com"
        <boris.brezillon@free-electrons.com>,
        "alexandre.belloni@free-electrons.com"
        <alexandre.belloni@free-electrons.com>,
        "tbultel@pixelsurmer.com" <tbultel@pixelsurmer.com>
To: Harini Katakam <harinikatakamlinux@gmail.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0044.outbound.protection.outlook.com ([104.47.40.44]:2429
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752728AbdACKsA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 05:48:00 -0500
In-Reply-To: <CAFcVECK1vt7Hu4tgSZ2+kKpMxoT-wpikMDq65HaxRv-EMgobHA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PkZyb206IEhhcmluaSBLYXRha2FtIFttYWlsdG86aGFyaW5pa2F0YWthbWxpbnV4QGdtYWlsLmNv
bV0gDQo+U2VudDogMyBzdHljem5pYSAyMDE3IDA2OjA2DQo+U3ViamVjdDogUmU6IFtSRkMgUEFU
Q0ggbmV0LW5leHQgdjQgMS8yXSBtYWNiOiBBZGQgMTU4OCBzdXBwb3J0IGluIENhZGVuY2UgR0VN
Lg0KPg0KPkhpIFJpY2hhcmQsDQo+DQo+T24gTW9uLCBKYW4gMiwgMjAxNyBhdCA5OjQzIFBNLCBS
aWNoYXJkIENvY2hyYW4gPHJpY2hhcmRjb2NocmFuQGdtYWlsLmNvbT4gd3JvdGU6DQo+PiBPbiBN
b24sIEphbiAwMiwgMjAxNyBhdCAwMzo0NzowN1BNICswMTAwLCBOaWNvbGFzIEZlcnJlIHdyb3Rl
Og0KPj4+IExlIDAyLzAxLzIwMTcgw6AgMTI6MzEsIFJpY2hhcmQgQ29jaHJhbiBhIMOpY3JpdCA6
DQo+Pj4gPiBUaGlzIENhZGVuY2UgSVAgY29yZSBpcyBhIGNvbXBsZXRlIGRpc2FzdGVyLg0KPj4+
DQo+Pj4gV2VsbCwgaXQgZXZvbHZlZCBhbmQgcHJvcG9zZSBzZXZlcmFsIG9wdGlvbnMgdG8gZGlm
ZmVyZW50IFNvQyANCj4+PiBpbnRlZ3JhdG9ycy4gVGhpcyBpcyBub3Qgc29tZXRoaW5nIHVudXN1
YWwuLi4NCj4+PiBJIHN1c3BlY3QgYXMgd2VsbCB0aGF0IHNvbWUgb3RoZXIgbmV0d29yayBhZGFw
dGVycyBoYXZlIHRoZSBzYW1lIA0KPj4+IHdlYWtuZXNzIGNvbmNlcm5pbmcgUFRQIHRpbWVzdGFt
cCBpbiBzaW5nbGUgcmVnaXN0ZXIgYXMgdGhlIGVhcmx5IA0KPj4+IHJldmlzaW9ucyBvZiB0aGlz
IElQLg0KPj4NCj4+IEl0IGFwcGVhcnMgdGhhdCB0aGlzIGNvcmUgY2FuIG5laXRoZXIgbGF0Y2gg
dGhlIHRpbWUgb24gcmVhZCBvciB3cml0ZSwgDQo+PiBvciBldmVuIGxhdGNoIHRpbWUgc3RhbXBz
LiAgSSBoYXZlIHdvcmtlZCB3aXRoIG1hbnkgZGlmZmVyZW50IFBUUCBIVyANCj4+IGltcGxlbWVu
dGF0aW9ucywgZXZlbiBlYXJseSBvbmVzIGxpa2Ugb24gdGhlIGl4cDR4eCwgYW5kIGl0IGlzIG5v
IA0KPj4gZXhhZ2dlcmF0aW9uIHRvIHNheSB0aGF0IHRoaXMgb25lIGlzIHVuaXF1ZWx5IGJyb2tl
bi4NCj4+DQo+Pj4gSSBzdXNwZWN0IHRoYXQgUmFmYWwgdGVuZCB0byBqdW1wIHRvbyBxdWlja2x5
IHRvIHRoZSBsYXRlc3QgSVAgDQo+Pj4gcmV2aXNpb25zIGFuZCBhZGQgbW9yZSBvcHRpb25zIHRv
IHRoaXMgc2VyaWVzOiBsZXQncyBub3QgdHJ5IHRvIHBvdXIgDQo+Pj4gdG9vIG11Y2ggdGhpbmdz
IGludG8gdGhpcyBjb2RlIHJpZ2h0IG5vdy4NCj4+DQo+PiBXaHkgY2FuJ3QgeW91IGNoZWNrIHRo
ZSBJUCB2ZXJzaW9uIGluIHRoZSBkcml2ZXI/DQo+DQo+VGhlcmUgaXMgYW4gSVAgcmV2aXNpb24g
cmVnaXN0ZXIgYnV0IGl0IHdvdWxkIGJlIHByb2JhYmx5IGJlIGJldHRlciB0byByZWx5IG9uICJj
YXBzIiBmcm9tIHRoZSBjb21wYXRpYmlsaXR5IHN0cmluZ3MgLSB0byBjb3ZlciBTb0Mgc3BlY2lm
aWMgaW1wbGVtZW50YXRpb25zLiBBbHNvLCB3aGVuIHRoaXMgZXh0ZW5kZWQgQkQgaXMgYWRkZWQg
KHdpdGggdGltZXN0YW1wKSwgYWRkaXRpb25hbCB3b3JkcyB3aWxsIG5lZWQgdG8gYmUgYWRkZWQg
c3RhdGljYWxseSB3aGljaCB3aWxsIGJlIGNvbnNpc3RlbnQgd2l0aCBBbmRyZWkncyBDT05GSUdf
IGNoZWNrcy4NCldlIGNhbiBkaXN0aW5ndWlzaCBJUCBjb3JlcyB3aXRoIGFuZCB3aXRob3V0IFBU
UCBzdXBwb3J0IGJ5IHJlYWRpbmcgRGVzaWduIENvbmZpZ3VyYXRpb24gUmVnaXN0ZXIuIEJ1dCB0
byBkaXN0aW5ndWlzaCBJUCBjb3JlcyB3aXRoIHRpbWVzdGFtcHMgaW4gYnVmZmVyIGRlc2NyaXB0
b3JzIGFuZCB3aGljaCBzdXBwb3J0IG9ubHkgZXZlbnQgcmVnaXN0ZXJzLCB3ZSBjYW4gb25seSBj
aGVjayBJUCB2ZXJzaW9uIGJ5IHJlYWRpbmcgdGhlIHJldmlzaW9uIElEIHJlZ2lzdGVyIGFuZCBi
YXNlIG9uIHRoYXQuDQpJIGFncmVlIHdpdGggSGFyaW5pLCBjb21wYXRpYmlsaXR5IHN0cmluZ3Mg
Y291bGQgYmUgYmV0dGVyLiBCdXQgd2UgbWlnaHQgZW5kIHVwIHdpdGggbWFueSBkaWZmZXJlbnQg
Y29uZmlndXJhdGlvbiBpbiB0aGUgZnV0dXJlLg0KV2UgY291bGQgdXNlIG9ubHkgZGVzY3JpcHRv
ciBhcHByb2FjaCBidXQgdGhlcmUgYXJlIG1hbnkgQXRtZWwncyBjb3JlcyBvbiB0aGUgbWFya2V0
IHdoaWNoIHN1cHBvcnQgb25seSBldmVudCByZWdpc3RlcnMuDQo=
