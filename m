From: Nogah Frankel <nogahf@mellanox.com>
Subject: RE: [PATCH iproute2 v5 2/4] ifstat: Add extended statistics to ifstat
Date: Tue, 7 Feb 2017 12:59:11 +0000
Message-ID: <DB5PR05MB1895D24A0C4AD0F7832EDC4EAC430@DB5PR05MB1895.eurprd05.prod.outlook.com>
References: <1485434681-33947-1-git-send-email-nogahf@mellanox.com>
 <1485434681-33947-3-git-send-email-nogahf@mellanox.com>
 <20170203100725.3d0b9791@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
        "roszenrami@gmail.com" <roszenrami@gmail.com>,
        "jbenc@redhat.com" <jbenc@redhat.com>,
        "sergei.shtylyov@cogentembedded.com"
        <sergei.shtylyov@cogentembedded.com>,
        Jiri Pirko <jiri@mellanox.com>,
        "Elad Raz" <eladr@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Yotam Gigi <yotamg@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0065.outbound.protection.outlook.com ([104.47.0.65]:3780
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754015AbdBGM7Q (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 7 Feb 2017 07:59:16 -0500
In-Reply-To: <20170203100725.3d0b9791@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IC0tLS0tT3JpZ2luYWwgTWVzc2FnZS0tLS0tDQo+IEZyb206IFN0ZXBoZW4gSGVtbWluZ2Vy
IFttYWlsdG86c3RlcGhlbkBuZXR3b3JrcGx1bWJlci5vcmddDQo+IFNlbnQ6IEZyaWRheSwgRmVi
cnVhcnkgMDMsIDIwMTcgODowNyBQTQ0KPiBUbzogTm9nYWggRnJhbmtlbCA8bm9nYWhmQG1lbGxh
bm94LmNvbT4NCj4gQ2M6IG5ldGRldkB2Z2VyLmtlcm5lbC5vcmc7IHJvb3BhQGN1bXVsdXNuZXR3
b3Jrcy5jb207IHJvc3plbnJhbWlAZ21haWwuY29tOw0KPiBqYmVuY0ByZWRoYXQuY29tOyBzZXJn
ZWkuc2h0eWx5b3ZAY29nZW50ZW1iZWRkZWQuY29tOyBKaXJpIFBpcmtvDQo+IDxqaXJpQG1lbGxh
bm94LmNvbT47IEVsYWQgUmF6IDxlbGFkckBtZWxsYW5veC5jb20+OyBJZG8gU2NoaW1tZWwNCj4g
PGlkb3NjaEBtZWxsYW5veC5jb20+OyBZb3RhbSBHaWdpIDx5b3RhbWdAbWVsbGFub3guY29tPjsg
T3IgR2VybGl0eg0KPiA8b2dlcmxpdHpAbWVsbGFub3guY29tPg0KPiBTdWJqZWN0OiBSZTogW1BB
VENIIGlwcm91dGUyIHY1IDIvNF0gaWZzdGF0OiBBZGQgZXh0ZW5kZWQgc3RhdGlzdGljcyB0byBp
ZnN0YXQNCj4gDQo+IE9uIFRodSwgMjYgSmFuIDIwMTcgMTQ6NDQ6MzkgKzAyMDANCj4gTm9nYWgg
RnJhbmtlbCA8bm9nYWhmQG1lbGxhbm94LmNvbT4gd3JvdGU6DQo+IA0KPiA+IEV4dGVuZGVkIHN0
YXRzIGFyZSBwYXJ0IG9mIHRoZSBSVE1fR0VUU1RBVFMgbWV0aG9kLiBUaGlzIHBhdGNoIGFkZHMg
dGhlbQ0KPiA+IHRvIGlmc3RhdC4NCj4gPiBXaGlsZSBleHRlbmRlZCBzdGF0cyBjYW4gY29tZSBp
biBtYW55IGZvcm1zLCB3ZSBzdXBwb3J0IG9ubHkgdGhlDQo+ID4gcnRubF9saW5rX3N0YXRzNjQg
c3RydWN0IGZvciB0aGVtICh3aGljaCBpcyB0aGUgNjQgYml0cyB2ZXJzaW9uIG9mIHN0cnVjdA0K
PiA+IHJ0bmxfbGlua19zdGF0cykuDQo+ID4gV2Ugc3VwcG9ydCBzdGF0cyBpbiB0aGUgbWFpbiBu
ZXN0aW5nIGxldmVsLCBvciBvbmUgbG93ZXIuDQo+ID4gVGhlIGV4dGVuc2lvbiBjYW4gYmUgY2Fs
bGVkIGJ5IGl0cyBuYW1lIG9yIGFueSBzaG9ydGVuIG9mIGl0LiBJZiB0aGVyZSBpcw0KPiA+IG1v
cmUgdGhhbiBvbmUgbWF0Y2hlZCwgdGhlIGZpcnN0IG9uZSB3aWxsIGJlIHBpY2tlZC4NCj4gPg0K
PiA+IFRvIGdldCB0aGUgZXh0ZW5kZWQgc3RhdHMgdGhlIGZsYWcgLXggPHN0YXRzIHR5cGU+IGlz
IHVzZWQuDQo+ID4NCj4gPiBTaWduZWQtb2ZmLWJ5OiBOb2dhaCBGcmFua2VsIDxub2dhaGZAbWVs
bGFub3guY29tPg0KPiA+IFJldmlld2VkLWJ5OiBKaXJpIFBpcmtvIDxqaXJpQG1lbGxhbm94LmNv
bT4NCj4gDQo+IFNvcnJ5IEkgd2FzIGNvbmZ1c2VkIGJlY2F1c2UgUlRNX0dFVFNUQVRTIGNvbnRh
aW5zIG11bHRpcGxlIHN0YXRpc3RpY3MuDQo+IFlvdXIgcGF0Y2ggaXMgYWJvdXQgZ2V0dGluZyBM
SU5LX1hTVEFUUyBhbmQgYWZ0ZXIgbG9va2luZyBpbiBtb3JlIGRldGFpbCwgeW91IGFyZQ0KPiBj
b3JyZWN0IHRoaXMgc2hvdWxkIGJlIGFuIG9wdGlvbi4gQWx0aG91Z2ggaXQgd291bGQgbWFrZSBz
ZW5zZSB0byBzaG93IHRoaXMgYXMgYWRkaXRpb24NCj4gdG8gdGhlIGJhc2ljIHN0YXRpc3RpY3Mu
IEFuZCB3aGVuIEkgdGVzdGVkIGl0IG5vIG91dHB1dCBoYXBwZW5zIHdoaWNoIHNlZW1zIGNvbmZ1
c2luZy4NCj4gDQo+ICQgLi9taXNjL2lmc3RhdCAtcCAteCBjcHVfaGl0cw0KPiAja2VybmVsDQo+
IEludGVyZmFjZSAgICAgICAgUlggUGt0cy9SYXRlICAgIFRYIFBrdHMvUmF0ZSAgICBSWCBEYXRh
L1JhdGUgICAgVFggRGF0YS9SYXRlDQo+ICAgICAgICAgICAgICAgICAgUlggRXJycy9Ecm9wICAg
IFRYIEVycnMvRHJvcCAgICBSWCBPdmVyL1JhdGUgICAgVFggQ29sbC9SYXRlDQo+IA0KDQpOb3Qg
YWxsIGRldmljZXMgc3VwcG9ydCB0aGlzIHhzdGF0Lg0KRG8geW91IHByZWZlciBhbm90aGVyIHBy
aW50IGluIHRoaXMgY2FzZT8NCg0KQWJvdXQgcHJpbnRpbmcgYm90aCB0aGUgeHN0YXQgYW5kIHRo
ZSBkZWZhdWx0IHN0YXRzIHRvZ2V0aGVyLCBpdCBtYXkgYmUgcHJvYmxlbWF0aWMgc2luY2UgDQpp
ZnN0YXQgaXMgYWJvdXQgZGlmZnMuIEkgdGhpbmsgaXQgaXMgYmV0dGVyIHRoYXQgb25lIGlmc3Rh
dCBjYWxsIGZvciBhIHNwZWNpZmljIHN0YXRzLCB3b24ndCBjaGFuZ2UNCnRoZSBvdGhlciBzdGF0
cyBkYXRhLiAoQW5kIHNpbmNlIHdlIGFyZSB0YWxraW5nIGFib3V0IGRpZmZzLCByZWFkaW5nIGRh
dGEgbWVhbmluZyBjaGFuZ2luZw0KaXQpLg0KDQo+IFdoYXQgSSB3YXMgaW50ZW5kaW5nIGluIGVh
cmxpZXIgZGlzY3Vzc2lvbiB3YXMgdXNpbmcgSUZMQV9TVEFUU19MSU5LXzY0IHdoaWNoIHdvdWxk
DQo+IGFsbG93IHN1cHBvcnRpbmcgNjQgYml0IHN0YXRpc3RpY3Mgb24gMzIgYml0IHBsYXRmb3Jt
cy4NCj4gDQo=
