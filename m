From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: Fix uninitialized variable in
 genl_validate_assign_mc_groups()
Date: Thu, 28 Nov 2013 18:25:05 -0500 (EST)
Message-ID: <20131128.182505.1593147138692009632.davem@davemloft.net>
References: <1385208110-17120-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: johannes.berg@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab3K1XZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Nov 2013 18:25:07 -0500
In-Reply-To: <1385208110-17120-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR2VlcnQgVXl0dGVyaG9ldmVuIDxnZWVydEBsaW51eC1tNjhrLm9yZz4NCkRhdGU6IFNh
dCwgMjMgTm92IDIwMTMgMTM6MDE6NTAgKzAxMDANCg0KPiBuZXQvbmV0bGluay9nZW5ldGxpbmsu
YzogSW4gZnVuY3Rpb24goWdlbmxfdmFsaWRhdGVfYXNzaWduX21jX2dyb3Vwc6I6DQo+IG5ldC9u
ZXRsaW5rL2dlbmV0bGluay5jOjIxNzogd2FybmluZzogoWVycqIgbWF5IGJlIHVzZWQgdW5pbml0
aWFsaXplZCBpbiB0aGlzDQo+IGZ1bmN0aW9uDQo+IA0KPiBDb21taXQgMmE5NGZlNDhmMzJjY2Y3
MzIxNDUwYTJjYzA3ZjJiNzI0YTQ0NGU1YiAoImdlbmV0bGluazogbWFrZSBtdWx0aWNhc3QNCj4g
Z3JvdXBzIGNvbnN0LCBwcmV2ZW50IGFidXNlIikgc3BsaXQgZ2VubF9yZWdpc3Rlcl9tY19ncm91
cCgpIGluIG11bHRpcGxlDQo+IGZ1bmN0aW9ucywgYnV0IGRyb3BwZWQgdGhlIGluaXRpYWxpemF0
aW9uIG9mIGVyci4NCj4gDQo+IEluaXRpYWxpemUgZXJyIHRvIHplcm8gdG8gZml4IHRoaXMuDQo+
IA0KPiBTaWduZWQtb2ZmLWJ5OiBHZWVydCBVeXR0ZXJob2V2ZW4gPGdlZXJ0QGxpbnV4LW02OGsu
b3JnPg0KPiAtLS0NCj4gUXVlc3Rpb246IElzIHRoZSBmb3JfZWFjaF9uZXRfcmN1KCkgbG9vcCBp
biBnZW5sX3ZhbGlkYXRlX2Fzc2lnbl9tY19ncm91cHMoKQ0KPiAgICAgICAgICAgZ3VhcmFudGVl
ZCB0byBsb29wIGF0IGxlYXN0IG9uY2U/DQo+IAkgIElmIHllcywgdGhpcyBpcyBhIGZhbHNlIHBv
c2l0aXZlLg0KDQpBcHBsaWVkLCBidXQgeWVzIGl0J3MgYSBmYWxzZSBwb3NpdGl2ZS4gIFRoZXJl
IGlzIGFsd2F5cyAmaW5pdF9uZXQgc28gdGhlDQpsb29wIGFsd2F5cyBpdGVyYXRlcyBhdCBsZWFz
dCBvbmNlLg0K
