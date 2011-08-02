From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] cxgb3i: ref count cdev access to prevent modification
 while in use
Date: Mon, 01 Aug 2011 22:00:19 -0400
Message-ID: <u5x31032ldl0f9efqk1mukrt.1312250375568@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, divy@chelsio.com, swise@chelsio.com,
	kxie@chelsio.com
To: David Miller <davem@davemloft.net>, swise@opengridcomputing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53645 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753637Ab1HBCDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 22:03:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

QXJnaCEgTXkgYmFkLiAgSWxsIHJlc3VibWl0IHRvIGxpbnV4LXNjc2kKTmVpbAoKRGF2aWQgTWls
bGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0PiB3cm90ZToKCj5Gcm9tOiBTdGV2ZSBXaXNlIDxzd2lz
ZUBvcGVuZ3JpZGNvbXB1dGluZy5jb20+Cj5EYXRlOiBNb24sIDAxIEF1ZyAyMDExIDA5OjQyOjU3
IC0wNTAwCj4KPj4gCj4+Pj4gU2lnbmVkLW9mZi1ieTogTmVpbCBIb3JtYW48bmhvcm1hbkB0dXhk
cml2ZXIuY29tPgo+Pj4+IENDOiBEaXZ5IExlIFJheTxkaXZ5QGNoZWxzaW8uY29tPgo+Pj4+IEND
OiBTdGV2ZSBXaXNlPHN3aXNlQGNoZWxzaW8uY29tPgo+Pj4+IENDOiAiRGF2aWQgUy4gTWlsbGVy
IjxkYXZlbUBkYXZlbWxvZnQubmV0Pgo+Pj4gRGl2eSwgU3RldmUsIEkgdGhpbmsgRGF2ZSBpcyB3
YWl0aW5nIGZvciBhbiBBQ0sgZnJvbSBvbmUgb2YgeW91IHRvLAo+Pj4gc2luY2UgeW91J3JlCj4+
PiB0aGUgbGlzdGVkIG1haW50YWluZXJzLgo+Pj4gTmVpbAo+PiAKPj4gS2FyZW4gaXMgdGhlIGN4
Z2IzaSBtYWludGFpbmVyLCBidXQgSSBqdXN0IG5vdyByZXZpZXdlZCB0aGUgcGF0Y2ggYW5kCj4+
IGl0IGxvb2tzIGdvb2QuICBEaXZ5IGlzIG9uIHZhY2F0aW9uIGZvciBhIGZldyB3ZWVrcy4gIEkg
dGhpbmsgaXRzIG9rCj4+IHRvIHB1bGwgaXQgaW4gc2luY2UgS2FyZW4gYWxyZWFkeSBhY2tlZCBp
dC4KPgo+QW5kIGp1c3QgdG8gbWFrZSBjbGVhciB0aGlzIG5lZWRzIHRvIGdvIHZpYSB0aGUgU0NT
SSB0cmVlIG5vdCB2aWEgbWUuCj4K

