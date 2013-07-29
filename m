From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net/fec: call netif_carrier_off when not having link
Date: Mon, 29 Jul 2013 02:14:10 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE015D5D24@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1374758875-7926-1-git-send-email-u.kleine-koenig@pengutronix.de>
	 <20130725090352.574b874d@nehalam.linuxnetplumber.net>
	 <9848F2DB572E5649BA045B288BE08FBE015C9315@039-SN2MPN1-023.039d.mgd.msft.net>
 <1374852712.1666.20.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	=?utf-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	Li Frank-B20596 <B20596@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>,
	Hector Palacios <hector.palacios@digi.com>,
	Tim Sander <tim.sander@hbm.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Thomas Gleixner <tglx@linutronix.de>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.187] ([213.199.154.187]:51339 "EHLO
	db8outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752243Ab3G2CPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jul 2013 22:15:25 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T24gRnJpLCAyMDEzLTA3LTI2IGF0IDExOjMyIFBNLCBCZW4gSHV0Y2hpbmdzIHdyb3RlOg0KPm5l
dGlmX3N0b3BfcXVldWUoKSAqbXVzdCBub3QqIGJlIGNhbGxlZCBiZWZvcmUgbmV0aWZfY2Fycmll
cl9vZmYoKSwgb3RoZXJ3aXNlIHRoZSBUWCB3YXRjaGRvZyBjYW4gZmlyZSBpbW1lZGlhdGVseS4N
Cj5UaGUgVFggd2F0Y2hkb2cgb25seSBrbm93cyB3aGVuIHRoZSBsYXN0IHBhY2tldCB3YXMgcGFz
c2VkIHRvIHRoZSBkcml2ZXIsIG5vdCB3aGVuIHRoZSBxdWV1ZSB3YXMgc3RvcHBlZC4NCj5UaGUg
bGFzdCBwYWNrZXQgY291bGQgaGF2ZSBiZWVuIGFkZGVkIGFuIGFyYml0cmFyaWx5IGxvbmcgdGlt
ZSBiZWZvcmUgdGhlIGxpbmsgd2VudCBkb3duLCB0aGVyZWZvcmUgaXQgbWF5IGFwcGVhciB0aGF0
IHRoZSB0aW1lb3V0IGhhcyBhbHJlYWR5IGV4cGlyZWQuLg0KPg0KPkFsdGhvdWdoIGl0IGlzIHNh
ZmUgdG8gY2FsbCBuZXRpZl9zdG9wX3F1ZXVlKCkgYWZ0ZXIgbmV0aWZfY2Fycmllcl9vZmYoKSwg
aXQgaXMgbm90IHVzZWZ1bC4NCj5uZXRpZl9zdG9wX3F1ZXVlKCkgc2hvdWxkIG9ubHkgYmUgY2Fs
bGVkIGZyb20geW91ciBuZG9fc3RhcnRfeG1pdCBvcGVyYXRpb24gYW5kIG9ubHkgYmVjYXVzZSB0
aGUgcXVldWUgaXMgZnVsbC4gDQo+QW55IG90aGVyIHJlYXNvbiB0byBzdG9wIHNob3VsZCBiZSBj
b21tdW5pY2F0ZWQgdG8gdGhlIGtlcm5lbCB1c2luZyBuZXRpZl9jYXJyaWVyX29mZigpIG9yIG5l
dGlmX2RldmljZV9kZXRhY2goKS4NCj4NCj5CZW4uDQoNCkFncmVlLg0KSSByZW1lbWJlciB5b3Ug
c2FpZDoNClRoZSB3YXRjaGRvZyBmaXJlcyB3aGVuIHRoZSBzb2Z0d2FyZSBxdWV1ZSBoYXMgYmVl
biBzdG9wcGVkICphbmQqIHRoZSBsaW5rIGhhcyBiZWVuIHJlcG9ydGVkIGFzIHVwIGZvciBvdmVy
IGRldi0+d2F0Y2hkb2dfdGltZW8gdGlja3MuDQpUaGUgc29mdHdhcmUgcXVldWUgc2hvdWxkIGJl
IHN0b3BwZWQgaWYgdGhlIGhhcmR3YXJlIHF1ZXVlIGlzIGZ1bGwgb3IgbmVhcmx5IGZ1bGwuICBJ
ZiB0aGUgc29mdHdhcmUgcXVldWUgcmVtYWlucyBzdG9wcGVkIGFuZCB0aGUgbGluayBpcyBzdGls
bCByZXBvcnRlZCB1cCwgdGhlbiBvbmUgb2YgdGhlc2UgdGhpbmdzIGlzIGhhcHBlbmluZzoNCg0K
MS4gVGhlIGxpbmsgd2VudCBkb3duIGJ1dCB0aGUgZHJpdmVyIGRpZG4ndCBub3RpY2UsIG9yIHNl
bnQgYSB0cmFuc21pdCBwYWNrZXQgd2hpY2ggbmV2ZXIgY29tcGxldGVzIDIuIFRYIGNvbXBsZXRp
b25zIGFyZSBub3QgYmVpbmcgaW5kaWNhdGVkIG9yIGhhbmRsZWQgY29ycmVjdGx5IDMuIFRoZSBo
YXJkd2FyZSBUWCBwYXRoIGhhcyBsb2NrZWQgdXAgNC4gVGhlIGxpbmsgaXMgc3RhbGxlZCBieSBl
eGNlc3NpdmUgcGF1c2UgZnJhbWVzIG9yIGNvbGxpc2lvbnMgNS4gVGltZW91dCBpcyB0b28gbG93
IGFuZC9vciBsb3cgd2F0ZXJtYXJrIGlzIHRvbyBoaWdoICh0aGVyZSBtYXkgYmUgb3RoZXIgZXhw
bGFuYXRpb25zKQ0KDQpUaGUgd2F0Y2hkb2cgaXMgcHJpbWFyaWx5IG1lYW50IHRvIGRlYWwgd2l0
aCBjYXNlIDMsIHRob3VnaCBhbGwgb2YgY2FzZXMgMS0zIG1heSBiZSB3b3JrZWQgYXJvdW5kIGJ5
IHJlc2V0dGluZyB0aGUgaGFyZHdhcmUuDQoNCg0KVGhhbmtzLA0KQW5keQ0K
