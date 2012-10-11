From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: alignment faults in 3.6
Date: Thu, 11 Oct 2012 16:39:38 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B703E@saturn3.aculab.com>
References: <20121005082439.GF4625@n2100.arm.linux.org.uk>  <20121011103257.GO4625@n2100.arm.linux.org.uk>  <1349952574.21172.8604.camel@edumazet-glaptop>  <201210111228.25995.arnd@arndb.de>  <1349959248.21172.8970.camel@edumazet-glaptop> <5076C78E.1020408@gmail.com> <1349963227.21172.9188.camel@edumazet-glaptop> <5076E472.8030703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Arnd Bergmann" <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>,
	"Russell King - ARM Linux" <linux@arm.linux.org.uk>,
	"Jon Masters" <jonathan@jonmasters.org>, <netdev@vger.kernel.org>,
	=?utf-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>
To: "Rob Herring" <robherring2@gmail.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45356 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1758770Ab2JKPtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2012 11:49:51 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 05787-02 for <netdev@vger.kernel.org>;
 Thu, 11 Oct 2012 16:49:47 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <5076E472.8030703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IA0KPiBOb3QgZXhhY3RseS4gSXQgaXMgYXNrZWQgdG8gdG8gcGVyZm9ybSAyIDMyLWJpdCBsb2Fk
cyB3aGljaCBhcmUgY29tYmluZWQNCj4gaW50byBhIHNpbmdsZSBsZG0gKGxvYWQgbXVsdGlwbGUp
IHdoaWNoIGNhbm5vdCBoYW5kbGUgdW5hbGlnbmVkDQo+IGFjY2Vzc2VzLiBIZXJlJ3MgYSBzaW1w
bGUgZXhhbXBsZSB0aGF0IGRvZXMgdGhlIHNhbWUgdGhpbmc6DQo+IA0KPiB2b2lkIHRlc3QoY2hh
ciAqIGJ1ZikNCj4gew0KPiAJcHJpbnRmKCIlZCwgJWRcbiIsICooKHVuc2lnbmVkIGludCAqKSZi
dWZbMF0pLCAqKCh1bnNpZ25lZCBpbnQgKikmYnVmWzRdKSk7DQo+IH0NCg0KSGF2ZSB5b3UgYWN0
dWFsbHkgbG9va2VkIGF0IHdoYXQgYW4gQVJNIHByb2Nlc3NvciB0cmFkaXRpb25hbGx5IGRpZA0K
d2l0aCBtaXNhbGlnbmVkIG1lbW9yeSByZWFkcz8NCldoaWxlIHVzZWZ1bCwgaXQgcHJvYmFibHkg
d2Fzbid0IHdoYXQgd2FzIGludGVuZGVkLg0KDQpBY3R1YWxseSwgYW5kIElJUkMsIHNvbWUgdmVy
eSByZWNlbnQgQVJNIGNwdXMgd2lsbCBkbyB0aGUgJ2V4cGVjdGVkJw0KdGhpbmcgZm9yIHNpbmds
ZS13b3JkIGxvYWRzIGZyb20gbWlzYWxpZ25lZCBhZGRlc3Nlcy4NCkhvd2V2ZXIgdGhleSBhbG1v
c3QgY2VydGFpbmx5IHdvbid0IGZvciBsZG0vc3RtLg0KDQpUaGUgJ2xkbScgb3B0aW1pc2F0aW9u
IGZvciBhZGphY2VudCBtZW1vcnkgbG9hZHMgaXMgYWxzbyBkdWJpb3VzLg0KT24gYXQgbGVhc3Qg
c29tZSBBUk1zIGl0IGlzIHZlcnkgc2xvdyAobWlnaHQgb25seSBiZSBzdHJvbmdhcm1zKS4NCg0K
PiBTbyBJIGd1ZXNzIHRoZSBvbmx5IEFCSSBsZWdhbCB1bmFsaWduZWQgYWNjZXNzIGlzIGluIGEg
cGFja2VkIHN0cnVjdC4NCg0KQ29ycmVjdC4gQW5kIHlvdSBtdXN0bid0IHRyeSBjYXN0aW5nIHRo
ZSBhZGRyZXNzLCB0aGUgY29tcGlsZXIgaXMNCmFsbG93ZWQgdG8gcmVtZW1iZXIgd2hlcmUgaXQg
Y2FtZSBmcm9tLg0KKFRoaXMgY2F1c2VzIGEgbG90IG9mIGdyaWVmLi4uKQ0KDQpJZiB5b3UgYXJl
IHRhcmdldGluZyB0aGUgQVJNIGNwdSB0aGF0IGNhbiBkbyBtaXNhbGlnbmVkIHRyYW5zZmVycywN
CnRoZW4gZ2NjIHNob3VsZCBnZW5lcmF0ZSBzaW5nbGUgaW5zdHJ1Y3Rpb25zIGZvciBtaXNhbGln
bmVkIHN0cnVjdHVyZQ0KbWVtYmVycywgYW5kIG5ldmVyIGRvIHRoZSAnbGRtJyBvcHRpbWlzYXRp
b25zLg0KDQpCdXQsIHRoZSBJUCBoZWFkZXIgaXMgZXhwZWN0ZWQgdG8gYmUgYWxpZ25lZC4NCg0K
CURhdmlkDQoNCg==
