From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: Get rid of RCU callbacks in TC filters?
Date: Mon, 23 Oct 2017 11:10:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00A01A0@AcuExch.aculab.com>
References: <CAM_iQpU1hF9v1+bek9CQkdbjS_2nctwpaSXyiNLiBHPC6WEYKQ@mail.gmail.com>
 <20171018193548.GM3521@linux.vnet.ibm.com>
 <CAM_iQpWwaQuxZMidkVXsjDVwGcW+u-h5rczG2CO0s1RamRVUYQ@mail.gmail.com>
 <20171020165623.GM3521@linux.vnet.ibm.com>
 <CAM_iQpUL9xCrZCjCpcaBMyjSWEJ+1DsFMO6dwJVtVvz=zKJDxA@mail.gmail.com>
 <CAM_iQpUbPro-qauH-R5e6vBVMuOcC+qxSvRwkH69XjVK0Uau5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
        Chris Mi <chrism@mellanox.com>,
        "Linux Kernel Network Developers" <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jiri Pirko <jiri@resnulli.us>
To: 'Cong Wang' <xiyou.wangcong@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.181]:62001 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbdJWLKO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 07:10:14 -0400
In-Reply-To: <CAM_iQpUbPro-qauH-R5e6vBVMuOcC+qxSvRwkH69XjVK0Uau5g@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQ29uZyBXYW5nDQo+IFNlbnQ6IDIwIE9jdG9iZXIgMjAxNyAyMTo1Mg0KPiBUbzogUGF1
bCBFLiBNY0tlbm5leQ0KPiBDYzogSmFtYWwgSGFkaSBTYWxpbTsgQ2hyaXMgTWk7IExpbnV4IEtl
cm5lbCBOZXR3b3JrIERldmVsb3BlcnM7IERhbmllbCBCb3JrbWFubjsgRXJpYyBEdW1hemV0OyBE
YXZpZA0KPiBNaWxsZXI7IEppcmkgUGlya28NCj4gU3ViamVjdDogUmU6IEdldCByaWQgb2YgUkNV
IGNhbGxiYWNrcyBpbiBUQyBmaWx0ZXJzPw0KPiANCj4gT24gRnJpLCBPY3QgMjAsIDIwMTcgYXQg
MTozMSBQTSwgQ29uZyBXYW5nIDx4aXlvdS53YW5nY29uZ0BnbWFpbC5jb20+IHdyb3RlOg0KPiA+
IEFjdHVhbGx5LCBJIGp1c3QgdHJpZWQgdGhpcyBhcHByb2FjaCwgdGhpcyB3YXkgbWFrZXMgdGhl
IGNvcmUgdGMgZmlsdGVyDQo+ID4gY29kZSBoYXJkZXIgdG8gd2FpdCBmb3IgZmx5aW5nIGNhbGxi
YWNrcywgY3VycmVudGx5IHJjdV9iYXJyaWVyKCkgaXMNCj4gPiBlbm91Z2gsIHdpdGggb25lIG1v
cmUgc2NoZWR1bGVfd29yaygpIGFkZGVkIHdlIHByb2JhYmx5DQo+ID4gbmVlZCBmbHVzaF93b3Jr
cXVldWUoKS4uLiBIdWgsIHRoaXMgYWxzbyBtZWFucyBJIGNhbid0IHVzZSB0aGUNCj4gPiBnbG9i
YWwgd29ya3F1ZXVlIHNvIHNob3VsZCBhZGQgYSBuZXcgd29ya3F1ZXVlIGZvciB0YyBmaWx0ZXJz
Lg0KPiA+DQo+ID4gR29vZCBuZXdzIGlzIEkgc2VlbSB0byBtYWtlIGl0IHdvcmsgd2l0aG91dCBh
ZGRpbmcgbXVjaCBjb2RlLg0KPiA+IFN0YXkgdHVuZWQuIDspDQo+IA0KPiBIbW0sIGxvY2tkZXAg
YWxyZWFkeSBjb21wbGFpbnMgSSBoYXZlIGEgZGVhZGxvY2sgd2hlbiBmbHVzaGluZw0KPiB3b3Jr
cXVldWUgd2hpbGUgaG9kbGluZyBSVE5MIGxvY2ssIGJlY2F1c2UgY2FsbGJhY2tzIG5lZWQgUlRO
TA0KPiB0b28uLi4gU2VlIHRoZSByY3VfYmFycmllcigpIGluIHRjZl9ibG9ja19wdXQoKS4NCj4g
DQo+IFNvIHRoaXMgYXBwcm9hY2ggc2VlbXMgdG8gYmUgYSBkZWFkIGVuZC4gSXMgdGhlcmUgYW55
IHdheSBvdXQ/DQo+IA0KPiBQcm9iYWJseSB3ZSBoYXZlIHRvIGNvbnZlcnQgY2FsbF9yY3UoKSB0
byBzeW5jaHJvbml6ZV9yY3UoKSwNCj4gYnV0IHdpdGggYmF0Y2hpbmcgb2YgY291cnNlLg0KDQpM
b2NraW5nIGZvciBjYWxsYmFja3MgaXMgYWx3YXlzIGEgUElUQS4NCllvdSBhbHNvIG5lZWQgdG8g
c29ydCBvdXQgaG93IHRvICd1bmhvb2snIHRoZSBjYWxsYmFja3MuDQoNCklmIHlvdSByZXF1aXJl
IHRoZSBjYWxsZXIgaG9sZCB0aGUgcm50bF9sb2NrIHByaW9yIHRvIGFkZGluZw0Kb3IgcmVtb3Zp
bmcgY2FsbGJhY2tzLCBhbmQgZ3VhcmFudGVlIHRoYXQgdGhlIGZ1bmN0aW9ucyB3aWxsDQpiZSBj
YWxsZWQgd2l0aCB0aGUgcm50bF9sb2NrIGhlbGQgeW91IG1pZ2h0IGJlIG9rLg0KDQpPdGhlcndp
c2UgdGhlIG9uZSBzaWRlIGNhbid0IGRvIGl0cyAnZXhwZWN0ZWQnIGxvY2tpbmcgd2l0aG91dA0K
YSBwb3RlbnRpYWwgZGVhZGxvY2sgb3IgdXNlLWFmdGVyLWZyZWUuDQoNClRoZSBvbmx5IHdheSBJ
IGtub3cgdG8gYXZvaWQgdGhlIGlzc3VlcyByZW1vdmluZyB0aGUgY2FsbGJhY2tzDQppcyB0byBn
ZXQgdGhlIGNhbGxiYWNrIGZ1bmN0aW9uIGNhbGxlZCBmcm9tIGl0cyBub3JtYWwgc2NoZWR1bGlu
Zw0KcG9pbnQgd2l0aCBhbiBhcmd1bWVudCAocHJvYmFibHkgTlVMTCkgdGhhdCBpbmRpY2F0ZXMg
aXQgd2lsbA0KbmV2ZXIgYmUgY2FsbGVkIGFnYWluLg0KDQoJRGF2aWQNCg0K
