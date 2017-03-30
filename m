From: Vlad Zakharov <Vladislav.Zakharov@synopsys.com>
Subject: Re: [PATCH] ezchip: nps_enet: check if napi has been completed
Date: Thu, 30 Mar 2017 09:16:44 +0000
Message-ID: <1490865403.32756.21.camel@synopsys.com>
References: <1490784106-14489-1-git-send-email-vzakhar@synopsys.com>
         <20170329.143014.2001816338079751776.davem@davemloft.net>
         <CANn89iJ1+7CrF=hJj-_pLWV+EDXxhUZGOL+3je6zjE8dJDcr=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "eladkan@mellanox.com" <eladkan@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "noamca@mellanox.com" <noamca@mellanox.com>,
        "Vladislav.Zakharov@synopsys.com" <Vladislav.Zakharov@synopsys.com>,
        "linux-snps-arc@lists.infradead.org"
        <linux-snps-arc@lists.infradead.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "edumazet@google.com" <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CANn89iJ1+7CrF=hJj-_pLWV+EDXxhUZGOL+3je6zjE8dJDcr=A@mail.gmail.com>
Content-Language: en-US
Content-ID: <1858E27A4351E340B253FD2659B35D65@internal.synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SGkgRXJpYywNCg0KT24gV2VkLCAyMDE3LTAzLTI5IGF0IDE0OjQxIC0wNzAwLCBFcmljIER1bWF6
ZXQgd3JvdGU6DQo+IE9uIFdlZCwgTWFyIDI5LCAyMDE3IGF0IDI6MzAgUE0sIERhdmlkIE1pbGxl
ciA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4gd3JvdGU6DQo+IFNpZ25lZC1vZmYtYnk6IFZsYWQgWmFr
aGFyb3YgPHZ6YWtoYXJAc3lub3BzeXMuY29tPg0KPiA+IA0KPiA+IA0KPiA+IEFwcGxpZWQuDQo+
ID4gDQo+ID4gRXJpYywgaWYgdGhpcyBpcyByZWFsbHkgcmVxdWlyZWQgbm93LCB3ZSBoYXZlIDE0
OCBicm9rZW4gZHJpdmVycyBzdGlsbC4NCj4gDQo+IFBpZWNlIG9mIGNha2UgOi8NCj4gDQo+IElm
IHdlIGdldCBtb3JlIHJlcG9ydHMgbGlrZSB0aGF0LCB3ZSBtaWdodCBpbXBsZW1lbnQgYSBsb2dp
YyB0bw0KPiBwcmV2ZW50IGluZmluaXRlIGxvb3BzLg0KPiANCj4gSXQgaXMgbm90IGNsZWFyIHRv
IG1lIHdoYXQgZXhhY3RseSBoYXBwZW5lZCB0byB0aGlzIGRyaXZlciwgc2luY2UNCj4gdGVzdGlu
ZyBuYXBpX2NvbXBsZXRlX2RvbmUoKSB3YXMgbm90IG1hbmRhdG9yeS4NCg0KSSBhbSBub3Qgc3Vy
ZSB3aGF0IGlzIGhhcHBlbmluZyB3aXRoIG90aGVyIGRyaXZlcnMsIGJ1dCBpbiBjYXNlIG9mIGV6
Y2hpcMKgbnBzX2VuZXQgZHJpdmVyIGFmdGVyIHRoZSBmb2xsb3dpbmcgY29tbWl0Og0KMzllNmM4
MjA4ZDdiNmZiOWQyMDQ3ODUwZmIzMzI3ZGI1NjdiNTY0Yg0KDQppZiB3ZSBnb3QgaW50byBOQVBJ
X1NUQVRFX01JU1NFRCBzdGF0ZSB0aGUgZm9sbG93aW5nIGhhcHBlbmVkOg0KaW4gbnBzX2VuZXRf
cG9sbCBmdW5jIHdlIHdlcmUgY2FsbGluZyBuYXBpX2NvbXBsZXRlX2RvbmUoKSAod2hpY2ggcmVz
ZXQgTUlTU0VEIHN0YXRlIGJ1dCBsZWZ0IFNDSEVEIHN0YXRlKSBhbmQgYWZ0ZXINCnRoYXQgd2l0
aG91dCBhbnkgY2hlY2tzIHdlcmUgZW5hYmxpbmcgaW50ZXJydXB0cy4NCg0KVGhlbiB3ZSBvYnZp
b3VzbHkgd2VyZSBnZXR0aW5nIGludG8gbnBzX2VuZXRfaXJxX2hhbmxkZXIoKSBpZiBpcnEgd2Fz
IHBlbmRpbmcgKGl0IGlzIHZlcnkgcG9zc2JpbGUgc3RhdGUpLiBJZiB3ZSBsb29rDQppbnNpZGUg
dGhpcyBmdW5jdGlvbiB3ZSB3aWxsIHNlZSB0aGF0IGl0IGRpc2FibGVzIGludGVycnVwdHMgb25s
eSBpbiBjYXNlIG5hcGlfc2NoZWRfcHJlcCgpIHJldHVybnMgdHJ1ZS4gSW4gaXRzIHR1cm4NCm5h
cGlfc2NoZWRfcHJlcCgpIHJldHVybnMgdHJ1ZSBvbmx5IGluIGNhc2UgaXQgY2hhbmdlcyBzdGF0
ZSBmcm9tIG5vbi1TQ0hFRCB0byBTQ0hFRC4gQnV0IGluIG91ciBjYXNlIGFzIFNDSEVEIGhhZCBi
ZWVuDQphbHJlYWR5IHNldCBpdCBzZXQgTUlTU0VEIHN0YXRlIGFuZCB0aGVuIHJldHVybmVkIGZh
bHNlLiBTbyBhdCB0aGF0IHBvaW50IHdlIGhhZCBhbHJlYWR5IGJlZW4gdHJhcHBlZDogYWZ0ZXIg
ZXhpdGluZyBpcnENCmhhbmxkZXIgd2Ugd2VyZSBnZXR0aW5nIGludG8gbnBzX2VuZXRfaXJxX2hh
bmxkZXIoKSBhZ2FpbiBhbmQgYWdhaW4gYXMgd2UgY291bGRuJ3QgcmVzY2luZCBwZW5kaW5nIGly
cSBzaWduYWwgYW5kDQpkaXNhYmxlIGNvcnJlc3BvbmRpbmcgaXJxLsKgDQoNCi0tIA0KQmVzdCBy
ZWdhcmRzLA0KVmxhZCBaYWtoYXJvdiA8dnpha2hhckBzeW5vcHN5cy5jb20+
