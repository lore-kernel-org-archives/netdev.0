From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: replace cnt & rtt with struct in
 pkts_acked()
Date: Tue, 10 May 2016 23:49:55 -0400 (EDT)
Message-ID: <20160510.234955.1868414439108959364.davem@davemloft.net>
References: <1462911069-1834733-1-git-send-email-brakmo@fb.com>
	<20160510.234758.925276118117758879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ncardwell@google.com,
	eric.dumazet@gmail.com, ycheng@google.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751833AbcEKDt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2016 23:49:59 -0400
In-Reply-To: <20160510.234758.925276118117758879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogVHVlLCAxMCBN
YXkgMjAxNiAyMzo0Nzo1OCAtMDQwMCAoRURUKQ0KDQo+IEZyb206IExhd3JlbmNlIEJyYWttbyA8
YnJha21vQGZiLmNvbT4NCj4gRGF0ZTogVHVlLCAxMCBNYXkgMjAxNiAxMzoxMTowOSAtMDcwMA0K
PiANCj4+IFJlcGxhY2UgMiBhcmd1bWVudHMgKGNudCBhbmQgcnR0KSBpbiB0aGUgY29uZ2VzdGlv
biBjb250cm9sIG1vZHVsZXMnDQo+PiBwa3RzX2Fja2VkKCkgZnVuY3Rpb24gd2l0aCBhIHN0cnVj
dC4gVGhpcyB3aWxsIGFsbG93IGFkZGluZyBtb3JlDQo+PiBpbmZvcm1hdGlvbiB3aXRob3V0IGhh
dmluZyB0byBtb2RpZnkgZXhpc3RpbmcgY29uZ2VzdGlvbiBjb250cm9sDQo+PiBtb2R1bGVzICh0
Y3BfbnYgaW4gcGFydGljdWxhciBuZWVkcyBieXRlcyBpbiBmbGlnaHQgd2hlbiBwYWNrZXQNCj4+
IHdhcyBzZW50KS4NCj4+IA0KPj4gQXMgcHJvcG9zZWQgYnkgTmVhbCBDYXJkd2VsbCBpbiBoaXMg
Y29tbWVudHMgdG8gdGhlIHRjcF9udiBwYXRjaC4NCj4+IA0KPj4gU2lnbmVkLW9mZi1ieTogTGF3
cmVuY2UgQnJha21vIDxicmFrbW9AZmIuY29tPg0KPj4gQWNrZWQtYnk6IFl1Y2h1bmcgQ2hlbmcg
PHljaGVuZ0Bnb29nbGUuY29tPg0KPiANCj4gQXBwbGllZCwgdGhhbmtzLg0KDQpBY3R1YWxseSBJ
IGhhZCB0byByZXZlcnQsIHRoaXMgYnJlYWtzIHRoZSBidWlsZDoNCg0KbmV0L2lwdjQvdGNwX2ls
bGlub2lzLmM6IEluIGZ1bmN0aW9uIKF0Y3BfaWxsaW5vaXNfYWNrZWSiOg0KbmV0L2lwdjQvdGNw
X2lsbGlub2lzLmM6OTc6MTg6IGVycm9yOiBhc3NpZ25tZW50IG9mIG1lbWJlciChcnR0X3VzoiBp
biByZWFkLW9ubHkgb2JqZWN0DQogICBzYW1wbGUtPnJ0dF91cyA9IFJUVF9NQVg7DQoNCllvdSBj
YW4ndCBtYXJrIHRoaXMgYXJndW1lbnQgY29uc3QuDQo=
