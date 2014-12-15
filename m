From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: sti: Fix uninitialized pointer
 dereference if !OF
Date: Mon, 15 Dec 2014 11:48:29 -0500 (EST)
Message-ID: <20141215.114829.885744524649941189.davem@davemloft.net>
References: <1418642751-23308-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaLOQsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Dec 2014 11:48:31 -0500
In-Reply-To: <1418642751-23308-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IE1v
biwgMTUgRGVjIDIwMTQgMTI6MjU6NTEgKzAxMDANCg0KPiBJZiBDT05GSUdfT0YgaXMgbm90IHNl
dDoNCj4gDQo+IGRyaXZlcnMvbmV0L2V0aGVybmV0L3N0bWljcm8vc3RtbWFjL2R3bWFjLXN0aS5j
OiBJbiBmdW5jdGlvbiChc3RpX2R3bWFjX3BhcnNlX2RhdGGiOg0KPiBkcml2ZXJzL25ldC9ldGhl
cm5ldC9zdG1pY3JvL3N0bW1hYy9kd21hYy1zdGkuYzozMTg6IHdhcm5pbmc6IKFyc6IgaXMgdXNl
ZCB1bmluaXRpYWxpemVkIGluIHRoaXMgZnVuY3Rpb24NCj4gDQo+IG9mX3Byb3BlcnR5X3JlYWRf
c3RyaW5nKCkgd2lsbCByZXR1cm4gLUVOT1NZUyBpbiB0aGlzIGNhc2UsIGFuZCBycyB3aWxsDQo+
IGJlIGFuIHVuaW5pdGlhbGl6ZWQgcG9pbnRlci4NCj4gDQo+IFdoaWxlIHRoZSBmYWxsYmFjayBj
bG9jayBzZWxlY3Rpb24gaXMgYWxyZWFkeSBzZWxlY3RlZCBjb3JyZWN0bHkgaW4gdGhpcw0KPiBj
YXNlLCB0aGUgc3RyaW5nIGNvbXBhcmlzb25zIHNob3VsZCBiZSBza2lwcGVkIHRvbywgZWxzZSB0
aGUgc3lzdGVtIHdpbGwNCj4gY3Jhc2ggd2hpbGUgZGVyZWZlcmVuY2luZyB0aGUgdW5pbml0aWFs
aXplZCBwb2ludGVyLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogR2VlcnQgVXl0dGVyaG9ldmVuIDxn
ZWVydEBsaW51eC1tNjhrLm9yZz4NCg0KQXBwbGllZC4NCg==
