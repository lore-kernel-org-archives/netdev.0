From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Tue, 27 Sep 2011 01:32:47 -0400 (EDT)
Message-ID: <20110927.013247.336618301904552114.davem@davemloft.net>
References: <20110913194101.7497.65515.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: venkat.x.venkatsubra@oracle.com, netdev@vger.kernel.org
To: jonathan@ogc.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51889 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752678Ab1I0Fcx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 01:32:53 -0400
In-Reply-To: <20110913194101.7497.65515.stgit@build.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSm9uYXRoYW4gTGFsbGluZ2VyIDxqb25hdGhhbkBvZ2MudXM+DQpEYXRlOiBUdWUsIDEz
IFNlcCAyMDExIDE0OjQxOjAxIC0wNTAwDQoNCj4gQEAgLTU0OCw2ICs1NTAsNyBAQCBzdGF0aWMg
aW50IHJkc19pd19mbHVzaF9tcl9wb29sKHN0cnVjdCByZHNfaXdfbXJfcG9vbCAqcG9vbCwgaW50
IGZyZWVfYWxsKQ0KPiAgCQlzcGluX3VubG9ja19pcnFyZXN0b3JlKCZwb29sLT5saXN0X2xvY2ss
IGZsYWdzKTsNCj4gIAl9DQo+ICANCj4gKwlhdG9taWNfc3ViKHVucGlubmVkLCAmcG9sbC0+ZnJl
ZV9waW5uZWQpOw0KPiAgCWF0b21pY19zdWIobmNsZWFuZWQsICZwb29sLT5kaXJ0eV9jb3VudCk7
DQo+ICAJYXRvbWljX3N1YihuZnJlZWQsICZwb29sLT5pdGVtX2NvdW50KTsNCj4gIA0KDQpuZXQv
cmRzL2l3X3JkbWEuYzogSW4gZnVuY3Rpb24goXJkc19pd19mbHVzaF9tcl9wb29sojoNCm5ldC9y
ZHMvaXdfcmRtYS5jOjU1MzoyNDogZXJyb3I6IKFwb2xsoiB1bmRlY2xhcmVkIChmaXJzdCB1c2Ug
aW4gdGhpcyBmdW5jdGlvbikNCm5ldC9yZHMvaXdfcmRtYS5jOjU1MzoyNDogbm90ZTogZWFjaCB1
bmRlY2xhcmVkIGlkZW50aWZpZXIgaXMgcmVwb3J0ZWQgb25seSBvbmNlIGZvciBlYWNoIGZ1bmN0
aW9uIGl0IGFwcGVhcnMgaW4NCg0KSWYgeW91IGRpZG4ndCBldmVuIGJ1aWxkIHRlc3QgaXQsIEkg
a25vdyB5b3UgZGlkbid0IHRlc3QgaXQncw0KZnVuY3Rpb25hbGl0eSBlaXRoZXIuDQoNClRoaXMg
aXMgY3JhenkuDQoNCldlbGwgaWYgaXQncyBub3QgaW1wb3J0YW50IGVub3VnaCB0byBldmVuIGJ1
aWxkIHRlc3QgdGhpcyBjaGFuZ2UNCmJlZm9yZSB5b3UgcG9zdCBpdCwgdGhlbiBpdCBvYnZpb3Vz
bHkgZG9lc24ndCBtYXR0ZXIgaWYgdGhlIFJETUENCm1vZHVsZSBjcmFzaGVzIHRoZSBrZXJuZWwg
d2hlbiBpdCdzIHVubG9hZGVkLg0K
