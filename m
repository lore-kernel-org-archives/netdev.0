From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [E1000-devel] [next:akpm 16/587] drivers/net/ethernet/intel/igb/igb_main.c:6231:2: error: call to '__compiletime_assert_6235' declared with attribute error: BUILD_BUG_ON failed: SKB_WITH_OVERHEAD(IGB_RX_BUFSZ) < (NET_SKB_PAD + NET_IP_ALIGN + IGB_TS_HD
Date: Thu, 21 Feb 2013 09:42:28 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B715B@saturn3.aculab.com>
References: <5122101a.nBjTqFyZXZ+WuzPr%fengguang.wu@intel.com> <20130219142708.b454d98a.akpm@linux-foundation.org> <804857E1F29AAC47BF68C404FC60A1844D0099DF@ORSMSX102.amr.corp.intel.com> <CAL4WiirCCfN_Xi423sEJB5v=5hCR_3d8M26JmmG3VJ=fbH4-1g@mail.gmail.com> <51251303.9030803@intel.com> <1361388156.19353.216.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	<e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Daniel Santos" <daniel.santos@pobox.com>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Alexander Duyck" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55180 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751791Ab3BUJqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 04:46:35 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 31221-07 for <netdev@vger.kernel.org>;
 Thu, 21 Feb 2013 09:46:32 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1361388156.19353.216.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IFRoZSBwcm9ibGVtIGlzIHRoZSAyNTYgYnl0ZSBhbGlnbm1lbnQgZm9yIEwxX0NBQ0hFX0JZ
VEVTIGlzIGluY3JlYXNpbmcNCj4gPiB0aGUgc2l6ZSBvZiB0aGUgZGF0YSBhbmQgc2hhcmVkIGlu
Zm8gc2lnbmlmaWNhbnRseSBwdXNoaW5nIHVzIHBhc3QgdGhlDQo+ID4gMksgbGltaXQuDQo+ID4N
Cj4gPiBJJ2xsIGxvb2sgaW50byB0aGlzIHNpbmNlIGl0IGxpa2VseSBhZmZlY3RzIGl4Z2JlIGFz
IHdlbGwuDQoNCkRvZXNuJ3QgYSAyNTYgYnl0ZSBjYWNoZSBsaW5lIGNhdXNlIGlzc3VlcyBhbG1v
c3QgZXZlcnl3aGVyZQ0KYW55dGhpbmcgaXMgbWFya2VkIGFzICdjYWNoZV9hbGlnbmVkJyA/DQoN
ClNvbWUgb3RoZXIgc3RydWN0dXJlcyBoYXZlIG1lbWJlcnMgcGFydCB3YXkgZG93biBtYXJrZWQg
dGhhdCB3YXkNCnNvIHRoYXQgdGhlIDJuZCBjYWNoZSBsaW5lICh3aXRoIHNtYWxsZXIgbGluZXMp
IGNvbnRhaW5zIGENCmtub3duIHNldCBvZiBmaWVsZHMgKGVpdGhlciB0byBnZXQgdGhlbSB0b2dl
dGhlciwgb3Igb3V0IG9mIHRoZQ0KY2FjaGUgbGluZSBjb250YWluaW5nIHRoZSBmaXJzdCBwYXJ0
IG9mIHRoZSBkYXRhKS4NCg0KV2l0aCAyNTYgYnl0ZSBjYWNoZSBsaW5lcyB0aGUgZW50aXJlIHN0
cnVjdHVyZSB3b3VsZCBwcm9iYWJseSBiZQ0KYSBzaW5nbGUgY2FjaGUgbGluZSAtIGV4Y2VwdCB0
aGF0IGl0IGdldHMgZXh0ZW5kZWQgdG8gdHdvIGxpbmVzLg0KDQpJIGtub3cgdGhhdCBzb21lIHBl
b3BsZSBoYXZlIGEgaGFiaXQgb2YgYWxsb2NhdGluZyBtdXRleCBpbiB0aGVpcg0Kb3duIGNhY2hl
IGxpbmUgKHdpdGggbm90aGluZyBlbHNlKSwgdGhhdCBhbHNvIGRvZXNuJ3QgbWFrZSBzZW5zZQ0K
dG8gbWUgLSBlc3BlY2lhbGx5IHdpdGggbGFyZ2UgY2FjaGUgbGluZXMgKEkgZG9uJ3Qga25vdyBp
ZiB0aGVyZQ0KYW55IG9mIHRob3NlIGluIExpbnV4KS4NCg0KCURhdmlkDQoNCg==
