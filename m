From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] rcu: fix a race in hlist_nulls_for_each_entry_rcu macro
Date: Wed, 22 May 2013 15:23:19 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7247@saturn3.aculab.com>
References: <519B38EC.90401@yandex-team.ru>  <20130521120906.GD3578@linux.vnet.ibm.com>  <1369143885.3301.221.camel@edumazet-glaptop>  <519B8908.9080007@yandex-team.ru>  <1369150693.3301.233.camel@edumazet-glaptop>  <519BB90B.6080706@yandex-team.ru>  <1369188080.3301.268.camel@edumazet-glaptop> <1369201765.3301.299.camel@edumazet-glaptop> <519CB2D8.103@yandex-team.ru> <1369225837.3301.324.camel@edumazet-glaptop> <AE90C24D6B3A694183C094C60CF0A2F6026B7246@saturn3.aculab.com> <1369229800.3301.332.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Roman Gushchin" <klamm@yandex-team.ru>,
	<paulmck@linux.vnet.ibm.com>,
	"Dipankar Sarma" <dipankar@in.ibm.com>, <zhmurov@yandex-team.ru>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <1369229800.3301.332.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiBIZXJlIHRoaXMgbG9vcHMgYmVnaW4gYnkNCj4gDQo+ICBzb21lcHRyID0gcmN1X2RlcmVmZXJl
bmNlKHNvbWVsb2NhdGlvbik7DQo+IA0KPiBNYXkgY2xhaW0gaXMgcmN1X2RlcmVmZXJlbmNlKCkg
c2hvdWxkIGZvcmNlIHRoZSBjb21waWxlciB0byByZWFkIGFnYWluDQo+IHNvbWVsb2NhdGlvbi4g
SXRzIGRvbmUgdGhhbmtzIHRvIEFDQ0VTU19PTkNFKCkuIEJ1dCBhcHBhcmVudGx5IGluIHRoZQ0K
PiBzcGVjaWZpYyBjYXNlIG9mICZoc2xvdC0+aGVhZCwgaXQgZG9lc250IHdvcmsuDQoNCkhtbW0u
Li4uDQojZGVmaW5lIEFDQ0VTU19PTkNFKHgpICgqKHZvbGF0aWxlIHR5cGVvZih4KSAqKSYoeCkp
DQpUaGF0IG1pZ2h0IGJlIGRvb21lZCB0byBmYWlsIGZvciBtdWNoIHRoZSBzYW1lIHJlYXNvbiBh
czoNCnZvaWQgeChzdHJ1Y3QgZm9vICp1bmFsaWduZWRfcHRyKQ0Kew0KICAgIGNoYXIgKnAgPSAo
dm9pZCAqKXVuYWxpZ25lZF9wdHI7DQogICAgbWVtY3B5KHRndCwgcCwgc2l6ZW9mICpwKTsNCn0N
CmdlbmVyYXRlcyBhbGlnbm1lbnQgZmF1bHRzLg0KQW5kIHRoYXQgY2FzdHMgdG8gYSB1bmlvbiB0
eXBlIGRvbid0IGdldCBhcm91bmQgJ3N0cmljdCBhbGlhc2luZycuDQoNCkJhc2ljYWxseSB0aGUg
Y29tcGlsZXIgbWFrZXMgdXNlIG9mIHRoZSBmYWN0IHRoYXQgeW91IHNob3VsZA0KY2FzdCBhZGRy
ZXNzZXMgYmFjayB0byB0aGVpciBvcmlnaW5hbCB0eXBlIGJlZm9yZSBkZXJlZmVyZW5jaW5nIHRo
ZW0uDQoNClNvIEknbSBub3Qgc3VyZSB5b3UgY2FuIHVzZSBhIGNhc3QgdG8gYWRkIGEgdHlwZSBx
dWFsaWZpZXIuDQpUaGUgZnJvbnQtZW5kIGxldHMgeW91IHJlbW92ZSAnY29uc3QnLCBidXQgSSBz
dXNwZWN0IHRoZSBvcHRpbWlzZXINCmlzIHVzaW5nIHRoZSBvcmlnaW5hbCB0eXBlcy4NCg0KCURh
dmlkDQoNCg==
