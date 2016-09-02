From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net 2/2] sctp: not copying duplicate addrs to the
 assoc's bind address list
Date: Fri, 2 Sep 2016 13:22:05 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB00EF186@AcuExch.aculab.com>
References: <cover.1471605833.git.lucien.xin@gmail.com>
 <130956b1e880eab780162a795fde156d61d4de0f.1471605833.git.lucien.xin@gmail.com>
 <20160819175007.GB3578@hmsreliant.think-freely.org>
 <CADvbK_do3kQSotq7-PbvoCBBSwOBBdZtx=rR+Q2XX3_bhV4_0w@mail.gmail.com>
 <20160822142538.GA10323@hmsreliant.think-freely.org>
 <20160824112338.GB11144@localhost.localdomain>
 <CADvbK_dJbaze7qMsDp-7x0xANsXZX=JfYBNhKOo=2VgbM_ywZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Neil Horman <nhorman@tuxdriver.com>,
        network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        davem <davem@davemloft.net>, Vlad Yasevich <vyasevich@gmail.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>
To: 'Xin Long' <lucien.xin@gmail.com>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:53259 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbcIBNYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 09:24:36 -0400
In-Reply-To: <CADvbK_dJbaze7qMsDp-7x0xANsXZX=JfYBNhKOo=2VgbM_ywZg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogT2YgWGluIExvbmcNCj4gU2VudDogMjUgQXVndXN0IDIwMTYgMDU6MDQNCi4uLg0KPiBC
dXQgSSBzdGlsbCBwcmVmZXIgdGhlIGN1cnJlbnQgcGF0Y2guDQo+IDEuIFRoaXMgaXNzdWUgb25s
eSBoYXBwZW5zIHdoZW4gc2VydmVyIGJpbmQgJ0FOWScgYWRkcmVzc2VzLg0KPiAgICAgd2UgZG9u
J3QgbmVlZCB0byBhZGQgYW55IG5ldyBtZW1iZXJzIHRvIHN0cnVjdCBzY3RwX3NvY2thZGRyX2Vu
dHJ5Lg0KPiAgICAgZXNwZWNpYWxseSBpZiBpdCdzIGEgcmVhbGx5IGNvcm5lciBpc3N1ZSwgIHdl
IGZpeCB0aGlzIGFzIGFuIGltcHJvdmVtZW50Lg0KPiANCj4gMi4gSXQncyB5ZXQgdHdvIGlzc3Vl
cyAgaGVyZSwgdGhlIGR1cGxpY2F0ZSBhZGRycyBtYXkgYmUgZnJvbQ0KPiAgICBhKSBkaWZmZXJl
bnQgbG9jYWwgTklDcy4NCj4gICAgYikgdGhlIHNhbWUgb25lIE5JQy4NCj4gICAgSXQgbWF5IGJl
IHVuZXhwZWN0YWJsZSB0byBmaWx0ZXIgdGhlbSBpbiBORVRERVZfVVAvRE9XTiBldmVudHMuDQo+
IA0KPiAzLiBXZSBjaGVjayBpdCBvbmx5IHdoZW4gc2N0cCByZWFsbHkgYmluZHMgaXQsIGp1c3Qg
bGlrZSBzY3RwX2RvX2JpbmQuDQo+IA0KPiBXaGF0IGRvIHlvdSB0aGluayA/DQoNCkkgd2FudCB0
byBrbm93IHdoYXQga2luZCBvZiB3ZWVkIHRoZSBTQ1RQIGF1dGhvcnMgd2VyZSBzbW9raW5nIHdo
ZW4gdGhleQ0KZGVjaWRlZCBpdCB3YXMgYXBwcm9wcmlhdGUgdG8gcHV0IGFsbCBvZiBhIHN5c3Rl
bXMgSVAgYWRkcmVzc2VzIGluIHRoZQ0KY29va2llIGFuZCBjb29raWUtYWNrIG1lc3NhZ2VzLg0K
DQpJdCB3b3VsZCBiZSBuaWNlIHRvIGhhdmUgdGhlIGxvY2FsIGFkZHJlc3NlcyBzZWxlY3RlZCBi
eSB0aGUga2VybmVsIG9uIHRoZQ0KYmFzaXMgb2YgdGhlIHJlbW90ZSBhZGRyZXNzIC0gcmVtb3Zp
bmcgdGhlIG5lY2Vzc2l0eSBvZiB0aGUgYXBwbGljYXRpb24NCnRvIGtub3cgdGhlIGN1cnJlbnQg
bmV0d29yayB0b3BvbG9neSAoYW5kIElQIGFkZHJlc3NlcykgaW4gb3JkZXIgdG8gYmluZA0KdG8g
dGhlIGNvcnJlY3QgbG9jYWwgYWRkcmVzc2VzIGJlZm9yZSBtYWtpbmcgYW4gb3V0d2FyZCBjYWxs
Lg0KDQpUaGlzIHNvcnQgb2YgcmVxdWlyZXMgdGhhdCBsb2NhbCBhZGRyZXNzZXMgZm9yIGEgY29u
bmVjdGlvbiBhcmUgbW9yZSBvZiBhDQpwcm9wZXJ0eSBvZiB0aGUgcm91dGluZyB0YWJsZSB0aGFu
IGFueXRoaW5nIGVsc2UuDQoNCkNvbnNpZGVyIHRoZSBmb2xsb3dpbmcgbmV0d29yazoNCg0KICAg
IC0tLS0rLS0tLS0tLS0tLS0tLS0tKy0tLS0tLS0tLS0tLS0tLS0tLS0tLS0rLS0tLS0tLS0tDQog
ICAgICAgIHwgICAgICAgICAgICAgICB8ICAgICAgICAgICAgICAgICAgICAgIHwNCiAgICAgeC54
LjEuMSAgICAgICAgIHgueC4xLjIgICAgICAgICAgICAgICAgeS55LjEuMg0KICAgIDEwLjEuMS4x
ICAgICAgICAxMC4xLjEuMiAgICAgICAgICAgICAgIDEwLjEuMS4yDQogICAgICAgIHwgICAgICAg
ICAgICAgICB8ICAgICAgICAgICAgICAgICAgICAgIHwNCiAgICAtLS0tKy0tLS0tLS0tLS0tLS0t
LSsgICAgICAgICAgICAgICAgICAgICAgKy0tLS0tLS0tLQ0KDQpBIGNvbm5lY3Rpb24gZnJvbSB4
LnguMS4xIHRvIHgueC4xLjIgbmVlZHMgdG8gc3BlY2lmeSB0aGUgMTAuMS4xLiogYWRkcmVzc2Vz
LA0KYnV0IGEgY29ubmVjdGlvbiBmb3IgeC54LjEuMSB0byB5LnkuMS4yIG11c3Qgbm90Lg0KDQpJ
J20gbm90IGF0IHN1cmUgd2hldGhlciBpdCBpcyBwb3NzaWJsZSB0byBzZXR1cCBsaXN0ZW5lcihz
KSBvbiB4LnguMS4xDQp0aGF0IGNhbiBhY2NlcHQgY29ubmVjdGlvbnMgZnJvbSBib3RoIHgueC4x
LjIgYW5kIHkueS4xLjIuDQoNCglEYXZpZA0KDQo=
