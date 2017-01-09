From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net 1/2] r8152: fix the sw rx checksum is unavailable
Date: Mon, 9 Jan 2017 07:58:02 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB20106C4D6@RTITMBSV03.realtek.com.tw>
References: <ed0c9790-57be-8bca-cdd6-3a54ca24f0bd@pobox.com>
 <20161125095350.GA20653@kroah.com>
 <1816ec7e-2733-f4ba-5d30-29dbabd20aad@pobox.com>
 <20161125.115827.2014848246966159357.davem@davemloft.net>
 <0835B3720019904CB8F7AA43166CEEB201057793@RTITMBSV03.realtek.com.tw>
 <CAA=3Oqn5_5w+vrg9_7UtZ-5BEbZ9Pm=qdX3WoVZKaAkxcMXYXA@mail.gmail.com>
 <CAA=3Oqn1i0cFDw1yi=vWJuU=w-N+8T7i3+xx9qQtrQCatAi+8Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: David Miller <davem@davemloft.net>,
        "mlord@pobox.com" <mlord@pobox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        nic_swsd <nic_swsd@realtek.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        Ansis Atteka <aatteka@ovn.org>
To: Ansis Atteka <aatteka@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA=3Oqn1i0cFDw1yi=vWJuU=w-N+8T7i3+xx9qQtrQCatAi+8Q@mail.gmail.com>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

QW5zaXMgQXR0ZWthIFttYWlsdG86YWF0dGVrYUBuaWNpcmEuY29tXQ0KPiBTZW50OiBUdWVzZGF5
LCBKYW51YXJ5IDAzLCAyMDE3IDg6NDEgQU0NClsuLi5dDQo+IEhheWVzLCBpbiB5b3VyIGlwZXJm
IHJlcHJvZHVjdGlvbiBlbnZpcm9ubWVudCBkaWQgeW91DQo+IDEpIGNvbm5lY3Qgc2VuZGVyIGFu
ZCByZWNlaXZlciBkaXJlY3RseSB3aXRoIGFuIEV0aGVybmV0IGNhYmxlPw0KPiAyKSB1c2UgaXBl
cmYncyBUQ1AgbW9kZSBpbnN0ZWFkIG9mIFVEUCBtb2RlLCBiZWNhdXNlIEkgYmVsaWV2ZSB0aGF0
DQo+IHdpdGggVURQIG1vZGUgcGFja2V0cyBhcmUgbW9yZSBsaWtlbHkgdG8gYmUgc3BhcnNlbHkg
ZGlzdHJpYnV0ZWQ/DQo+IEFsc28sIHRoaXMgYnVnIGlzIHdheSBlYXNpZXIgdG8gcmVwcm9kdWNl
IHdoZW4gSVAgZnJhZ21lbnRhdGlvbiBraWNrcw0KPiBpbiBiZWNhdXNlIElQIGZyYWdtZW50cyBh
cmUgdHlwaWNhbGx5IHNlbnQgb3V0IHZlcnkgY2xvc2UgdG8gZWFjaA0KPiBvdGhlci4NCj4gMykg
d2VyZSB5b3UgcGx1Z2dpbmcgeW91ciBVU0IgRXRoZXJuZXQgZG9uZ2xlIGluIFVTQiAzLjAgcG9y
dCBvcg0KPiB3aGF0ZXZlciBNYXJrIHdhcyB1c2luZz8gSXQgc2VlbXMgdGhhdCBlYWNoIFVTQiBt
b2RlIGhhcyBkaWZmZXJlbnQNCj4gY29hbGVzY2UgcGFyYW1ldGVycyBhbmQgeW91cnMgbWlnaHQg
aGF2ZSB3b3JrICJvdXQgb2YgYm94Ij8NCg0KWWVzLiBJIGNvbm5lY3QgdGhlbSBkaXJlY3RseSBh
bmQgdXNlIGlwZXJmJ3MgVENQIG1vZGUuIEhvd2V2ZXIsDQpJIHRlc3QgdGhlIFJUTDgxNTIgd2hp
Y2ggb25seSBzdXBwb3J0IFVTQiAyLjAuIFRoZXJlZm9yZSwgSSBkb24ndA0KdGhpbmsgaXQgb2Nj
dXJzIHdpdGggZGlmZmVyZW50IGNvYWxlc2NlIHBhcmFtZXRlcnMuDQoNCj4gV2hpbGUgSSB3b3Vs
ZCBub3QgY2FsbCB0aGlzIGEgcHJvcGVyIGZpeCwgYmVjYXVzZSBpdCBzaW1wbHkgcmVkdWNlcw0K
PiBjb2FsZXNjaW5nIHRpbWVvdXRzIGJ5IG9yZGVyIG9mIDEwWCBhbmQgbW9zdCBsaWtlbHkgZG9l
cyBub3QgZWxpbWluYXRlDQo+IHNlY3VyaXR5IGFzcGVjdHMgb2YgdGhlIGJ1ZywgaXQgYXQgbGVh
c3QgbWFkZSBteSBzeXN0ZW0gZnVuY3Rpb25hbGx5DQo+IHN0YWJsZSBhbmQgSSBkb24ndCBzZWUg
ZWl0aGVyIG9mIHRob3NlIHR3byBidWdzIGluIG15IHNldHVwIGFueW1vcmU6DQoNCkRvIHlvdSB0
cnkgY29tbWl0IGE1OWU2ZDgxNTIyNiAoInI4MTUyOiBjb3JyZWN0IHRoZSByeCBlYXJseSBzaXpl
IiksDQpvciB5b3UgaGF2ZSB1c2VkIGl0Pw0KDQpCZXN0IFJlZ2FyZHMsDQpIYXllcw0KDQo=
