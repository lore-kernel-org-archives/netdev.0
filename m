From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rtnetlink: Fix problem with buffer allocation
Date: Tue, 21 Feb 2012 16:21:25 -0500 (EST)
Message-ID: <20120221.162125.1533105883101299190.davem@davemloft.net>
References: <20120221204715.22575.21711.stgit@gitlad.jf.intel.com>
	<20120221.161630.1122203779408129070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60753 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752438Ab2BUVV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 16:21:27 -0500
In-Reply-To: <20120221.161630.1122203779408129070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAyMSBG
ZWIgMjAxMiAxNjoxNjozMCAtMDUwMCAoRVNUKQ0KDQo+IA0KPiBHcmVnLCB3aGVyZSBpcyB0aGUg
Y29kZSB0aGF0IGd1YXJkcyB0aGUgYWN0dWFsIGR1bXBpbmcgb2YgdGhlIFZGDQo+IGluZm9ybWF0
aW9uIGJhc2VkIHVwb24gdGhlIGV4dCBtYXNrPw0KPiANCj4gSSBvbmx5IHNlZSB0aGUgZXh0IG1h
c2sgY29udHJvbGxpbmcgdGhlIHNpemluZyBvZiB0aGUgU0tCLiAgV2hhdCBnb29kDQo+IGlzIHRo
YXQgaWYgd2Ugc3RpbGwgZHVtcCB0aGUgVkZzPw0KDQpBY3R1YWxseSwgaXQncyBldmVuIHdvcnNl
LCB0aGlzIHRoaW5nIGRvZXNuJ3QgZXZlbiBjb21waWxlIGJlY2F1c2UNCnlvdSBoYXZlbid0IHVw
ZGF0ZWQgdGhlIGFjdHVhbCBpbXBsZW1lbnRhdGlvbiBvZiBydG5sX3ZmaW5mb19zaXplKCkNCnRv
IHRha2UgdGhlIG5ldyBtYXNrIGFyZ3VtZW50Lg0KDQpZb3UgZGlkbid0IGV2ZW4gY29tcGlsZSB0
ZXN0IHRoaXMsIGFyZSB5b3UgZnVja2luZyBraWRkaW5nIG1lPw0KDQpuZXQvY29yZS9ydG5ldGxp
bmsuYzogSW4gZnVuY3Rpb24goWlmX25sbXNnX3NpemWiOg0KbmV0L2NvcmUvcnRuZXRsaW5rLmM6
Nzg5Ojk6IGVycm9yOiB0b28gbWFueSBhcmd1bWVudHMgdG8gZnVuY3Rpb24goXJ0bmxfdmZpbmZv
X3NpemWiDQpuZXQvY29yZS9ydG5ldGxpbmsuYzo3MjY6MTk6IG5vdGU6IGRlY2xhcmVkIGhlcmUN
Cm1ha2VbMV06ICoqKiBbbmV0L2NvcmUvcnRuZXRsaW5rLm9dIEVycm9yIDENCm1ha2U6ICoqKiBb
bmV0L2NvcmUvcnRuZXRsaW5rLm9dIEVycm9yIDINCg==
