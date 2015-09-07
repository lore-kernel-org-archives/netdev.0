From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vxlan: Refactor vxlan_udp_encap_recv() to kill
 compiler warning
Date: Sun, 06 Sep 2015 19:48:15 -0700 (PDT)
Message-ID: <20150906.194815.191957136140104730.davem@davemloft.net>
References: <1441363772-20850-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: tgraf@suug.ch, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752950AbbIGCsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Sep 2015 22:48:15 -0400
In-Reply-To: <1441363772-20850-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IEZy
aSwgIDQgU2VwIDIwMTUgMTI6NDk6MzIgKzAyMDANCg0KPiBkcml2ZXJzL25ldC92eGxhbi5jOiBJ
biBmdW5jdGlvbiChdnhsYW5fdWRwX2VuY2FwX3JlY3aiOg0KPiBkcml2ZXJzL25ldC92eGxhbi5j
OjEyMjY6IHdhcm5pbmc6IKFpbmZvoiBtYXkgYmUgdXNlZCB1bmluaXRpYWxpemVkIGluIHRoaXMg
ZnVuY3Rpb24NCj4gDQo+IFdoaWxlIHRoaXMgd2FybmluZyBpcyBhIGZhbHNlIHBvc2l0aXZlLCBp
dCBjYW4gYmUga2lsbGVkIGVhc2lseSBieQ0KPiBnZXR0aW5nIHJpZCBvZiB0aGUgcG9pbnRlciBp
bnRlcm1lZGlhcnkgYW5kIHJlZmVycmluZyBkaXJlY3RseSB0byB0aGUNCj4gaXBfdHVubmVsX2lu
Zm8gc3RydWN0dXJlLg0KPiANCj4gU2lnbmVkLW9mZi1ieTogR2VlcnQgVXl0dGVyaG9ldmVuIDxn
ZWVydEBsaW51eC1tNjhrLm9yZz4NCg0KQXBwbGllZCwgdGhhbmtzLg0K
