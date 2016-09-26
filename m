From: =?ISO-8859-1?Q?J=F6rg?= Krause <joerg.krause@embedded.rocks>
Subject: Re: [PATCHv2 0/2] net: fec: Reset ethernet PHY whenever the
 enet_out clock is being enabled
Date: Mon, 26 Sep 2016 17:37:49 +0200
Message-ID: <1474904269.8465.2.camel@embedded.rocks>
References: <1452611876-451-1-git-send-email-LW@KARO-electronics.de>
 <20160112152405.GZ19062@n2100.arm.linux.org.uk>
 <20160112170444.11c412c5@ipc1.ka-ro>
 <20160112203002.GZ24441@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Mark Rutland <mark.rutland@arm.com>, Andrew Lunn <andrew@lunn.ch>,
 Stefan Agner <stefan@agner.ch>, Greg Ungerer <gerg@uclinux.org>,
 Nimrod Andy <B38611@freescale.com>, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
 Sascha Hauer <s.hauer@pengutronix.de>, devicetree@vger.kernel.org,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Richard Cochran <richardcochran@gmail.com>, Rob Herring <robh+dt@kernel.org>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 linux-arm-kernel@lists.infradead.org,
 Fabio Estevam <fabio.estevam@freescale.com>, Kevin Hao <haokexin@gmail.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Sascha Hauer <kernel@pengutronix.de>, Kumar Gala <galak@codeaurora.org>,
 Lucas Stach <l.stach@pengutronix.de>, Shawn Guo <shawnguo@kernel.org>,
 "David S. Miller" <davem@davemloft.net>, Philippe Reynes <tremyfr@gmail.com>
To: Uwe =?ISO-8859-1?Q?Kleine-K=F6nig?= <u.kleine-koenig@pengutronix.de>,
 Lothar =?ISO-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20160112203002.GZ24441@pengutronix.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

SGkgYWxsLAoKT24gVHVlLCAyMDE2LTAxLTEyIGF0IDIxOjMwICswMTAwLCBVd2UgS2xlaW5lLUvD
tm5pZyB3cm90ZToKPiBIZWxsbywKPiAKPiBPbiBUdWUsIEphbiAxMiwgMjAxNiBhdCAwNTowNDo0
NFBNICswMTAwLCBMb3RoYXIgV2HDn21hbm4gd3JvdGU6Cj4gPiAKPiA+ID4gCj4gPiA+IE9uIFR1
ZSwgSmFuIDEyLCAyMDE2IGF0IDA0OjE3OjU0UE0gKzAxMDAsIExvdGhhciBXYcOfbWFubiB3cm90
ZToKPiA+ID4gPiAKPiA+ID4gPiBUaGlzIHBhdGNoc2V0IGZpeGVzIGEgcmVncmVzc2lvbiBpbnRy
b2R1Y2VkIGJ5Cj4gPiA+ID4gY29tbWl0IGU4ZmNmY2Q1Njg0YSAoIm5ldDogZmVjOiBvcHRpbWl6
ZSB0aGUgY2xvY2sgbWFuYWdlbWVudAo+ID4gPiA+IHRvIHNhdmUgcG93ZXIiKQo+ID4gPiA+IGZv
ciBldGhlcm5ldCBQSFlzIHRoYXQgYXJlIHVzaW5nIEVORVRfT1VUIGFzIHJlZmVyZW5jZSBjbG9j
awo+ID4gPiA+IChvbiBpLk1YNiBvciBpLk1YMjgpCj4gPiA+ID4gCj4gPiA+ID4gQ2hhbmdlcyB2
cy4gdjE6Cj4gPiA+ID4gLSBmaXhlZCByZWZlcmVuY2UgdG8gdGhlIGNvbW1pdCB0aGF0IGludHJv
ZHVjZWQgdGhlIHJlZ3Jlc3Npb24uCj4gPiA+ID4gLSBkcm9wcGVkIHBhdGNoIHRvIHVzZSBncGlv
ZCBmcmFtZXdvcmsuIFRoaXMgc2hvdWxkIGJlIGFkZGVkCj4gPiA+ID4gbGF0ZXIsCj4gPiA+ID4g
wqAgYWZ0ZXIgdGhlIGFmZmVjdGVkIERUQnMgaGF2ZSBiZWVuIHVwZGF0ZWQgdG8gc3BlY2lmeSB0
aGUKPiA+ID4gPiBjb3JyZWN0Cj4gPiA+ID4gwqAgZ3Bpb19mbGFncy4KPiA+ID4gPiAKPiA+ID4g
PiBQYXRjaCBvdmVydmlldzoKPiA+ID4gPiAxLiBjbGVhbnVwIHBhdGNoIHRvIHJlbW92ZSByZWR1
bmRhbnQgTlVMTCBjaGVja3MKPiA+ID4gPiAyLiBjYWxsIGZlY19yZXNldF9waHkoKSBhZnRlciB0
aGUgRU5FVF9PVVQgY2xvY2sgaGFzIGJlZW4KPiA+ID4gPiBlbmFibGVkCj4gPiA+IAo+ID4gPiBJ
IGRlZmluaXRlbHkgd2FudCB0byB0ZXN0IHRoZXNlIG9uIG15IFNvbGlkUnVuIGJvYXJkcyBiZWZv
cmUKPiA+ID4gdGhlc2UgZ2V0Cj4gPiA+IG1lcmdlZDogdGhlIEFSODAzNSBvbiB0aGVyZSBpcyBj
b25maWd1cmVkIHZpYSBwaW4tc3RyYXBzLCBhbmQKPiA+ID4gdGhlbgo+ID4gPiBmdXJ0aGVyIHR3
ZWFrZWQgd2l0aCBQSFkgcXVpcmtzLsKgwqBSZXNldHRpbmcgd2l0aCB0aGUgaU1YNiBpbiB0aGUK
PiA+ID4gd3Jvbmcgc3RhdGUgbWF5IHJlc3VsdCBpbiB0aGUgQVI4MDM1IGJlaW5nIHJlY29uZmln
dXJlZCAoZXZlbgo+ID4gPiBqdW1waW5nCj4gPiA+IHRvIGEgZGlmZmVyZW50IE1ESU8gYWRkcmVz
cykgYW5kIGNlcnRhaW5seSB3b3VsZCBuZWVkIHRoZSBQSFkKPiA+ID4gcXVpcmtzCj4gPiA+IHJl
LXJ1bm5pbmcuCj4gPiA+IAo+ID4gQXMgZmFyIGFzIEkgY2FuIHRlbGwsIGFsbCBTb2xpZFJ1biBi
b2FyZHMgZG8gbm90IHNwZWNpZnkgdGhlCj4gPiBlbmV0X291dAo+ID4gY2xvY2sgaW4gdGhlIGR0
Yiwgc28gdGhlIFBIWSByZXNldCBiZWhhdmlvdXIgc2hvdWxkIGJlIHVuYWZmZWN0ZWQKPiA+IGJ5
Cj4gPiB0aGlzIHBhdGNoIG9uIHRob3NlIGJvYXJkcywgc2luY2UgdGhlIGFkZGl0aW9uYWwgZmVj
X3Jlc2V0X3BoeSgpCj4gPiBjYWxsIGlzCj4gPiBmcmFtZWQgYnk6Cj4gPiBpZiAoZmVwLT5jbGtf
ZW5ldF9vdXQpIHsKPiA+IAkuLi4KPiA+IH0KPiA+IAo+ID4gQnV0IHZlcmlmeWluZyB0aGlzIGV4
cGxpY2l0bHkgaXMgb2YgY291cnNlIGEgZ29vZCBpZGVhLgo+IAo+IElmIHRoZSBTb2xpZFJ1biBi
b2FyZHMgZG9uJ3QgZG8gdGhpcywgdGhpcyBkb2Vzbid0IG1lYW4gaXQncyBzYWZlIGluCj4gZ2Vu
ZXJhbC4gVGhlIHByb2JsZW0gaXMgcmVhbCwgaXNuJ3QgaXQ/CgpBbnl0aGluZyBuZXcgb24gdGhp
cyB0b3BpYz8gSSBhbSBmYWNpbmcgdGhlIHNhbWUgaXNzdWUgd2l0aCBMaW51eApLZXJuZWwgNC43
IGFuZCB0aGUgTUNTQyBMQU44NzIwQSBvbiBhbiBpLk1YMjggYm9hcmQuCgpJIGZvdW5kIHRoaXMg
cGF0Y2ggb24gcGF0Y2h3b3JrIGFuZCBpdCB3b3JrcyBmb3IgbWUuCgpCZXN0IHJlZ2FyZApKw7Zy
ZyBLcmF1c2UKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
CmxpbnV4LWFybS1rZXJuZWwgbWFpbGluZyBsaXN0CmxpbnV4LWFybS1rZXJuZWxAbGlzdHMuaW5m
cmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2xp
bnV4LWFybS1rZXJuZWwK
