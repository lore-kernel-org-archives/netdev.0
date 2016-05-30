From: "Coelho, Luciano" <luciano.coelho@intel.com>
Subject: Re: [PATCH] iwlwifi: mvm: avoid harmless -Wmaybe-uninialized warning
Date: Mon, 30 May 2016 20:37:02 +0000
Message-ID: <1464640622.19317.54.camel@intel.com>
References: <1464354462-1940949-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>,
	"Harel, Moshe" <moshe.harel@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Gottlieb, Matti" <matti.gottlieb@intel.com>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28103 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752176AbcE3UhK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 May 2016 16:37:10 -0400
In-Reply-To: <1464354462-1940949-1-git-send-email-arnd@arndb.de>
Content-Language: en-US
Content-ID: <13CC8AB7B6DAAE4297FE3E682CC24901@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCAyMDE2LTA1LTI3IGF0IDE1OjA3ICswMjAwLCBBcm5kIEJlcmdtYW5uIHdyb3RlOg0K
PiBnY2MgaXMgYXBwYXJlbnRseSB1bmFibGVsIHRvIHRyYWNrIHRoZSBzdGF0ZSBvZiB0aGUgbG9j
YWwgJ3Jlc3BfdjInDQo+IHZhcmlhYmxlIGFjcm9zcyB0aGUga3phbGxvYygpIGZ1bmN0aW9uLCBh
bmQgd2FybnMgYWJvdXQgdGhlIHJlc3BvbnNlDQo+IHZhcmlhYmxlIGJlaW5nIHVzZWQgd2l0aG91
dCBhbiBpbml0aWFsaXphdGlvbjoNCj4gDQo+IGRyaXZlcnMvbmV0L3dpcmVsZXNzL2ludGVsL2l3
bHdpZmkvbXZtL252bS5jOiBJbiBmdW5jdGlvbg0KPiDigJhpd2xfbXZtX3VwZGF0ZV9tY2PigJk6
DQo+IGRyaXZlcnMvbmV0L3dpcmVsZXNzL2ludGVsL2l3bHdpZmkvbXZtL252bS5jOjcyNzozNjog
d2FybmluZzoNCj4g4oCYbWNjX3Jlc3BfdjHigJkgbWF5IGJlIHVzZWQgdW5pbml0aWFsaXplZCBp
biB0aGlzIGZ1bmN0aW9uIFstV21heWJlLQ0KPiB1bmluaXRpYWxpemVkXQ0KPiDCoMKgwqByZXNw
X2NwLT5uX2NoYW5uZWxzID0gbWNjX3Jlc3BfdjEtPm5fY2hhbm5lbHM7DQo+IGRyaXZlcnMvbmV0
L3dpcmVsZXNzL2ludGVsL2l3bHdpZmkvbXZtL252bS5jOjcyMTozOiB3YXJuaW5nOg0KPiDigJht
Y2NfcmVzcOKAmSBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24gWy1X
bWF5YmUtDQo+IHVuaW5pdGlhbGl6ZWRdDQo+IMKgwqDCoG1lbWNweShyZXNwX2NwLCBtY2NfcmVz
cCwgcmVzcF9sZW4pOw0KPiANCj4gVGhlIHdhcm5pbmcgc2hvd2VkIHVwIGluIHg4NiBhbGxtb2Rj
b25maWcgYWZ0ZXIgbXkgcGF0Y2ggdG8NCj4gdW5oaWRlIC1XbWF5YmUtdW5pbml0aWFsaXplZCB3
YXJuaW5ncyBieSBkZWZhdWx0IHdhcyBtZXJnZWQsDQo+IHRob3VnaCBpdCBhbHdheXMgZXhpc3Rl
ZCBpbiByYW5kY29uZmlnIGJ1aWxkcy4gSSBkaWQgbm90DQo+IGNhdGNoIHRoZSB3YXJuaW5nIGVh
cmxpZXIgYmVjYXVzZSBJIHdhcyB0ZXN0aW5nIG9uIEFSTSwgd2hpY2gNCj4gbmV2ZXIgcHJvZHVj
ZWQgdGhlIHdhcm5pbmcuDQo+IA0KPiBUaGlzIHJlYXJyYW5nZXMgdGhlIGNvZGUgaW4gYSB3YXkg
dGhhdCBpbXByb3ZlcyByZWFkYWJpbGl0eSBmb3INCj4gYm90aCBodW1hbnMgYW5kIHRoZSBjb21w
aWxlciwgYW5kIHRoYXQgYXZvaWRzIHRoZSB3YXJuaW5nLg0KPiANCj4gU2lnbmVkLW9mZi1ieTog
QXJuZCBCZXJnbWFubiA8YXJuZEBhcm5kYi5kZT4NCj4gRml4ZXM6IDZmYTUyNDMwZjBiMyAoIml3
bHdpZmk6IG12bTogY2hhbmdlIG1jYyB1cGRhdGUgQVBJIikNCj4gLS0tDQoNClRoYW5rcywgQXJu
ZCEgSSBxdWV1ZWQgdGhpcyB2aWEgb3VyIGludGVybmFsIHRyZWUuDQoNCi0tDQpDaGVlcnMsDQpM
dWNhLg==
