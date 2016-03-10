From: Jonas Markussen <jonassm@ifi.uio.no>
Subject: Re: [PATCH v6 net-next 0/2] tcp: Redundant Data Bundling (RDB)
Date: Thu, 10 Mar 2016 01:45:00 +0000
Message-ID: <78983A17-6B0C-4A11-BE0E-A98FE699D1E3@ifi.uio.no>
References: <1445633413-3532-1-git-send-email-bro.devel+kernel@gmail.com>
 <1457028388-18226-1-git-send-email-bro.devel+kernel@gmail.com>
 <CAK6E8=eKu_0ReSDLYdyajxMyX2MaN=wDLHvq=u_tyNnMRS31sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: =?utf-8?B?QmVuZGlrIFLDuG5uaW5nIE9wc3RhZA==?= <bro.devel@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	Neal Cardwell <ncardwell@google.com>,
	Andreas Petlund <apetlund@simula.no>,
	Carsten Griwodz <griff@simula.no>,
	=?utf-8?B?UMOlbCBIYWx2b3JzZW4=?= <paalh@simula.no>,
	Kristian Evensen <kristian.evensen@gmail.com>,
	Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out4.uio.no ([129.240.10.15]:42668 "EHLO mail-out4.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964802AbcCJCCP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2016 21:02:15 -0500
In-Reply-To: <CAK6E8=eKu_0ReSDLYdyajxMyX2MaN=wDLHvq=u_tyNnMRS31sw@mail.gmail.com>
Content-Language: en-US
Content-ID: <EDE32F17D1142C4C9941F99B3F707F1E@mail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IE9uIDEwIE1hciAyMDE2LCBhdCAwMToyMCwgWXVjaHVuZyBDaGVuZyA8eWNoZW5nQGdvb2ds
ZS5jb20+IHdyb3RlOg0KPiANCj4gUFMuIEkgZG9uJ3QgdW5kZXJzdGFuZCBob3cgKG9sZCkgUkRC
IGNhbiBtYXNxdWVyYWRlIHRoZSBsb3NzZXMgYnkNCj4gc2tpcHBpbmcgRFVQQUNLcy4gUGVyaGFw
cyBhbiBleGFtcGxlIGhlbHBzLiBTdXBwb3NlIHdlIHNlbmQgNCBwYWNrZXRzDQo+IGFuZCB0aGUg
bGFzdCAzIHdlcmUgKHMpYWNrZWQuIFdlIHBlcmZvcm0gUkRCIHRvIHNlbmQgYSBwYWNrZXQgdGhh
dCBoYXMNCj4gcHJldmlvdXMgNCBwYXlsb2FkcyArIDEgbmV3IGJ5dGUuIFRoZSBzZW5kZXIgc3Rp
bGwgZ2V0cyB0aGUgbG9zcw0KPiBpbmZvcm1hdGlvbj8NCj4gDQoNCklmIEnigJl2ZSB1bmRlcnN0
b29kIHlvdSBjb3JyZWN0bHksIHlvdeKAmXJlIHRhbGtpbmcgYWJvdXQgc2VuZGluZyA0IA0KcGFj
a2V0cyBhbmQgdGhlIGZpcnN0IG9uZSBpcyBsb3N0Pw0KDQpJbiB0aGlzIGNhc2UsIFJEQiB3aWxs
IG5vdCBvbmx5IGJ1bmRsZSBvbiB0aGUgbGFzdC9uZXcgcGFja2V0IGJ1dCBhbHNvIA0KYXMgaXQg
c2VuZHMgcGFja2V0IDIgKHdoaWNoIHdpbGwgY29udGFpbiAxKzIpLCBwYWNrZXQgMyAoMSsyKzMp
IA0KYW5kIHBhY2tldCA0ICgxKzIrMys0KS4gDQoNClNvIHRoZSBmYWN0IHRoYXQgcGFja2V0IDEg
d2FzIGxvc3QgaXMgbWFzcXVlcmFkZWQgd2hlbiBpdCBpcyANCnJlY292ZXJlZCBieSBwYWNrZXQg
MiBhbmQgdGhlcmUgd29u4oCZdCBiZSBhbnkgZ2FwIGluIHRoZSBTQUNLIHdpbmRvdw0KaW5kaWNh
dGluZyB0aGF0IHBhY2tldCAxIHdhcyBsb3N0Lg0KDQpCZXN0IHJlZ2FyZHMsDQpKb25hcyBNYXJr
dXNzZW4=
