From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 2/5] net: split skb_checksum_help
Date: Tue, 24 Jan 2017 16:35:20 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB026CEA4@AcuExch.aculab.com>
References: <cover.1485177252.git.dcaratti@redhat.com>
 <532e1db70b6c40f1b1e5c60b5b51be9f3437a30b.1485177252.git.dcaratti@redhat.com>
 <CALx6S37E=OEkRego_u=oDuUgQUn9-NZLpupvbN_dge1rqF92CQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: 'Tom Herbert' <tom@herbertland.com>,
        Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.184]:56543 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750723AbdAXQf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 11:35:27 -0500
In-Reply-To: <CALx6S37E=OEkRego_u=oDuUgQUn9-NZLpupvbN_dge1rqF92CQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogVG9tIEhlcmJlcnQNCj4gU2VudDogMjMgSmFudWFyeSAyMDE3IDIxOjAwDQouLg0KPiBz
a2JfY2hlY2tzdW1faGVscCBpcyBzcGVjaWZpYyB0byB0aGUgSW50ZXJuZXQgY2hlY2tzdW0uIEZv
ciBpbnN0YW5jZSwNCj4gQ0hFQ0tTVU1fQ09NUExFVEUgY2FuIF9vbmx5XyByZWZlciB0byBJbnRl
cm5ldCBjaGVja3N1bSBjYWxjdWxhdGlvbg0KPiBub3RoaW5nIGVsc2Ugd2lsbCB3b3JrLiBDaGVj
a3N1bXMgYW5kIENSQ3MgYXJlIHZlcnkgZGlmZmVyZW50IHRoaW5ncw0KPiB3aXRoIHZlcnkgZGlm
ZmVyZW50IHByb2Nlc3NpbmcuIFRoZXkgYXJlIG5vdCBpbnRlcmNoYW5nZWFibGUsIGhhdmUNCj4g
dmVyeSBkaWZmZXJlbnQgcHJvcGVydGllcywgYW5kIGhlbmNlIGl0IGlzIGEgbWlzdGFrZSB0byB0
cnkgdG8gc2hvZQ0KPiBob3JuIHRoaW5ncyBzbyB0aGF0IHRoZXkgdXNlIGEgY29tbW9uIGluZnJh
c3RydWN0dXJlLg0KPiANCj4gSXQgbWlnaHQgbWFrZSBzZW5zZSB0byBjcmVhdGUgc29tZSBDUkMg
aGVscGVyIGZ1bmN0aW9ucywgYnV0IGxhc3QgdGltZQ0KPiBJIGNoZWNrZWQgdGhlcmUgYXJlIHNv
IGZldyB1c2VycyBvZiBDUkMgaW4gc2tidWZzIEknbSBub3QgZXZlbiBzdXJlDQo+IHRoYXQgd291
bGQgbWFrZSBzZW5zZS4NCg0KSSBjYW4gaW1hZ2luZSBob3JyaWQgdGhpbmdzIGhhcHBlbmluZyBp
ZiBzb21lb25lIHRyaWVzIHRvIGVuY2Fwc3VsYXRlDQpTQ1RQL0lQIGluIFVEUCAob3Igd29yc2Ug
VURQL0lQIGluIFNDVFApLg0KDQpGb3IgVURQIGluIFVEUCBJIHN1c3BlY3QgdGhhdCBDSEVDS1NV
TV9DT01QTEVURSBvbiBhbiBpbm5lciBVRFAgcGFja2V0DQphbGxvd3MgdGhlIG91dGVyIGNoZWNr
c3VtIGJlIGNhbGN1bGF0ZWQgYnkgaWdub3JpbmcgdGhlIGlubmVyIHBhY2tldA0KKHNpbmNlIGl0
IHN1bXMgdG8gemVybykuDQpUaGlzIGp1c3QgaXNuJ3QgdHJ1ZSBpZiBTQ1RQIGlzIGludm9sdmVk
Lg0KVGhlcmUgYXJlIHRyaWNrcyB0byBnZW5lcmF0ZSBhIGNyYyBvZiBhIGxvbmdlciBwYWNrZXQs
IGJ1dCB0aGV5J2Qgb25seQ0Kd29yayBmb3IgU0NUUCBpbiBTQ1RQLg0KDQpGb3Igbm9uLWVuY2Fw
c3VsYXRlZCBwYWNrZXRzIGl0IGlzIGEgZGlmZmVyZW50IG1hdHRlci4NCg0KCURhdmlkDQoNCg==
