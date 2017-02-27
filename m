From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 2/2] sctp: add support for MSG_MORE
Date: Mon, 27 Feb 2017 10:48:30 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE70E65@AcuExch.aculab.com>
References: <cover.1487440272.git.lucien.xin@gmail.com>
 <d6f2835b0bd655a563896e86648cbd9b4e01374e.1487440272.git.lucien.xin@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6C9B9@AcuExch.aculab.com>
 <CADvbK_dDgFc78dBCpTkNxM3kU-GAYbh6CCGTtO=r9ZeNyb2X0A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6E5BB@AcuExch.aculab.com>
 <CADvbK_d9dyL0PFPrAyNqFT_URNdq75NPdQe8tqQkFO4aCg2DdA@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DCFE6EDE0@AcuExch.aculab.com>
 <CADvbK_eauYUyUWMAn8Zkpk5hNnK-GDNO+3NCeuA-y=Y7SFnv5A@mail.gmail.com>
 <CADvbK_fS9bOzoRsY-TBKMUkJJZJ5NuouBcSt1=79kJVTAHc=UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: network dev <netdev@vger.kernel.org>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        "Vlad Yasevich" <vyasevich@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>
To: 'Xin Long' <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.186]:57955 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751620AbdB0Ktw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 05:49:52 -0500
In-Reply-To: <CADvbK_fS9bOzoRsY-TBKMUkJJZJ5NuouBcSt1=79kJVTAHc=UQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogWGluIExvbmcNCj4gU2VudDogMjcgRmVicnVhcnkgMjAxNyAwNDo0OQ0KLi4uDQo+ID4g
d2hhdCBJJ20gd29ycmllZCBhYm91dCBpcyBpZiB0aGUgbXNnX21vcmUgaXMgc2F2ZWQgaW4gYXNz
b2M6DQo+ID4gICAgICBjaGs0W2NsZWFyXSAtPiBjaGszIFtjbGVhcl0gLT4gY2hrMiBbY2xlYXJd
IC0+IGNoazEgW2NsZWFyXQ0KPiA+IHRoZW4gd2hlbiB5b3Ugc2VuZCBhIHNtYWxsIGNoa0Egd2l0
aCBNU0dfTU9SRSwNCj4gPiB0aGUgcXVldWUgd2lsbCBiZSBsaWtlOg0KPiA+ICAgICAgY2hrQSBb
c2V0XSAtPiBjaGs0W3NldF0gLT4gY2hrMyBbc2V0XSAtPiBjaGsyIFtzZXRdIC0+IGNoazEgW3Nl
dF0NCj4gPiBiZWNhdXNlIG1zZ19tb3JlIGlzIHNhdmVkIGluIGFzc29jLCBldmVyeSBjaHVuayBj
YW4gbG9vayBhdCBpdC4NCj4gPiBjaGsxIC0gY2hrNCBhcmUgYmlnIGVub3VnaCB0byBiZSBwYWNr
ZWQgaW50byBhIHBhY2tldCwgdGhleSB3ZXJlDQo+ID4gbm90IHNlbnQgbGFzdCB0aW1lIGJlY2F1
c2UgYSBsb3Qgb2YgY2h1bmtzIGFyZSBpbiB0aGUgcmV0cmFuc21pdA0KPiA+IHF1ZXVlLg0KDQpP
ciBqdXN0IHdhaXRpbmcgZm9yIHRyYW5zbWl0IHdpbmRvdyBzcGFjZS4NCg0KPiA+IEJ1dCBub3cg
ZXZlbiBpZiByZXRyYW5zbWl0IHF1ZXVlIGlzIG51bGwsIGNoazEtY2hrNCBhcmUgc3RpbGwgYmxv
Y2tlZC4NCj4gPg0KPiA+IGNhbiB5b3UgYWNjZXB0IHRoYXQgY2hrQSBtYXkgYmxvY2sgdGhlIG9s
ZCBjaHVua3MgPw0KPiBldmVuIGFsc28gYmxvY2sgdGhlIHJldHJhbnNtaXQgY2h1bmtzLg0KDQpJ
IGRvbid0IHNlZSBhIHByb2JsZW0sIHRoZSBhcHBsaWNhdGlvbiBpcyBhYm91dCB0byBzZW5kIGFu
b3RoZXIgY2h1bmsuDQpJdCBpcyBsaWtlbHkgdGhhdCB0aGUgd2hvbGUgbG90IHdpbGwgZ28gaW4g
b25lIHBhY2tldC4NCg0KSWYgdGhlIGNvbm5lY3Rpb24gaXMgZmxvdyBjb250cm9sbGVkIG9mZiAo
ZXZlbiBpZiBkdWUgdG8gcGFja2V0IGxvc3MpDQp0aGUgbWlub3IgZGVsYXkgd2FpdGluZyBmb3Ig
dGhlIGFwcGxpY2F0aW9uIHdvbid0IG1ha2UgYW55IHJlYWwgZGlmZmVyZW5jZS4NCkluZGVlZCBy
ZWR1Y2luZyB0aGUgbnVtYmVyIG9mIGV0aGVybmV0IGZyYW1lcyBtYXkgaGVscCBpbmNyZWFzZQ0K
b3ZlcmFsbCB0aHJvdWdocHV0Lg0KDQpEb2VzIGEgcmVxdWVzdCBmb3IgY2h1bmtzIHRvIGJlIHJl
dHJhbnNtaXR0ZWQgZm9yY2UgYSByZXNwb25zZSBwYWNrZXQgYmUgYnVpbHQ/DQpJZiBzbyBpdCB3
aWxsIHBpY2sgdXAgYWxsIHRoZSBxdWV1ZWQgZGF0YSBjaHVua3MgcmVnYXJkbGVzcyBvZiBhbnkg
c2F2ZWQNCk1TR19NT1JFIGJpdHMuDQoNCglEYXZpZA0KDQoNCg==
