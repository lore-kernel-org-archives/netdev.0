From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] cxgb3: Added private MAC address and
 provisioning packet handler for iSCSI
Date: Fri, 25 Sep 2009 13:42:39 -0700 (PDT)
Message-ID: <20090925.134239.193728924.davem@davemloft.net>
References: <200909250133.n8P1XAZb030062@localhost.localdomain>
	<20090925.121242.184886085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: base64
Cc: swise@opengridcomputing.com, divy@chelsio.com, rranjan@chelsio.com,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kxie@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37677
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751892AbZIYUmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2009 16:42:20 -0400
In-Reply-To: <20090925.121242.184886085.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRGF2aWQgTWlsbGVyIDxkYXZlbUBkYXZlbWxvZnQubmV0Pg0KRGF0ZTogRnJpLCAyNSBT
ZXAgMjAwOSAxMjoxMjo0MiAtMDcwMCAoUERUKQ0KDQo+IEZyb206IGt4aWVAY2hlbHNpby5jb20N
Cj4gRGF0ZTogVGh1LCAyNCBTZXAgMjAwOSAxODozMzoxMCAtMDcwMA0KPiANCj4+IDAwYzQ4N2Vk
NjYxYzA5MDQ3NTdhMjFiN2M5NThlYmE1OWU2ODQ4MmENCj4+IFtQQVRDSCBuZXQtbmV4dC0yLjZd
IGN4Z2IzOiBBZGRlZCBwcml2YXRlIE1BQyBhZGRyZXNzIGFuZCBwcm92aXNpb25pbmcgcGFja2V0
IGhhbmRsZXIgZm9yIGlTQ1NJDQo+PiANCj4+IFRoaXMgcGF0Y2ggYWRkZWQgc3VwcG9ydCBvZiBw
cml2YXRlIE1BQyBhZGRyZXNzIHBlciBwb3J0IGFuZCBwcm92aXNpb25pbmcNCj4+IHBhY2tldCBo
YW5kbGVyIGZvciBpU0NTSSB0cmFmZmljIG9ubHkuDQo+PiANCj4+IEFja2VkLWJ5OiBLYXJlbiBY
aWUgPGt4aWVAY2hlbHNpby5jb20+DQo+PiBBY2tlZC1ieTogRGl2eSBMZSBSYXkgPGRpdnlAY2hl
bHNpby5jb20+DQo+PiBTaWduZWQtb2ZmLWJ5OiBSYWtlc2ggUmFuamFuIDxycmFuamFuQGNoZWxz
aW8uY29tPg0KPiANCj4gQXBwbGllZCwgdGhhbmtzLg0KDQpUaGlzIGRvZXNuJ3QgZXZlbiBidWls
ZCwgcmV2ZXJ0aW5nOg0KDQpkcml2ZXJzL3Njc2kvY3hnYjNpL2N4Z2IzaV9pc2NzaS5jOiBJbiBm
dW5jdGlvbiDigJhjeGdiM2lfaG9zdF9zZXRfcGFyYW3igJk6DQpkcml2ZXJzL3Njc2kvY3hnYjNp
L2N4Z2IzaV9pc2NzaS5jOjcxODogZXJyb3I6IOKAmHN0cnVjdCBwb3J0X2luZm/igJkgaGFzIG5v
IG1lbWJlciBuYW1lZCDigJhpc2NzaV9pcHY0YWRkcuKAmQ0KZHJpdmVycy9zY3NpL2N4Z2IzaS9j
eGdiM2lfaXNjc2kuYzogSW4gZnVuY3Rpb24g4oCYY3hnYjNpX2hvc3RfZ2V0X3BhcmFt4oCZOg0K
ZHJpdmVycy9zY3NpL2N4Z2IzaS9jeGdiM2lfaXNjc2kuYzo3NTU6IGVycm9yOiDigJhzdHJ1Y3Qg
cG9ydF9pbmZv4oCZIGhhcyBubyBtZW1iZXIgbmFtZWQg4oCYaXNjc2lfaXB2NGFkZHLigJkNCm1h
a2VbM106ICoqKiBbZHJpdmVycy9zY3NpL2N4Z2IzaS9jeGdiM2lfaXNjc2kub10gRXJyb3IgMQ0K
