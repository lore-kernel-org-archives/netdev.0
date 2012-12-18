From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: TCP delayed ACK heuristic
Date: Tue, 18 Dec 2012 16:39:59 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B70F4@saturn3.aculab.com>
References: <270756364.27707018.1355842632348.JavaMail.root@redhat.com> <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "Ben Greear" <greearb@candelatech.com>,
	"David Miller" <davem@davemloft.net>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"Stephen Hemminger" <shemminger@vyatta.com>,
	"Rick Jones" <rick.jones2@hp.com>, "Thomas Graf" <tgraf@redhat.com>
To: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:42937 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932093Ab2LRQrW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 11:47:22 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22618-08 for <netdev@vger.kernel.org>;
 Tue, 18 Dec 2012 16:47:18 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <2088500005.27728019.1355843484620.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBEYXZpZCdzIHBvaW50IGlzIHRoYXQgd2UgY2FuIGRvIHNvbWUgaGV1cmlzdGljcyBmb3IgVENQ
DQo+IGRlbGF5ZWQgQUNLLCBzbyB0aGUgcXVlc3Rpb24gaXMgdGhhdCB3aGF0IGtpbmQgb2YgaGV1
cmlzdGljcw0KPiBjYW4gd2UgdXNlPw0KPiANCj4gUkZDMTEyMiBleHBsaWNpdGx5IG1lbnRpb25z
Og0KPiANCj4gICAgICAgICAgICAgQSBUQ1AgU0hPVUxEIGltcGxlbWVudCBhIGRlbGF5ZWQgQUNL
LCBidXQgYW4gQUNLIHNob3VsZCBub3QNCj4gICAgICAgICAgICAgYmUgZXhjZXNzaXZlbHkgZGVs
YXllZDsgaW4gcGFydGljdWxhciwgdGhlIGRlbGF5IE1VU1QgYmUNCj4gICAgICAgICAgICAgbGVz
cyB0aGFuIDAuNSBzZWNvbmRzLCBhbmQgaW4gYSBzdHJlYW0gb2YgZnVsbC1zaXplZA0KPiAgICAg
ICAgICAgICBzZWdtZW50cyB0aGVyZSBTSE9VTEQgYmUgYW4gQUNLIGZvciBhdCBsZWFzdCBldmVy
eSBzZWNvbmQNCj4gICAgICAgICAgICAgc2VnbWVudC4NCj4gDQo+IHNvIHRoaXMgcHJldmVudHMg
dXMgZnJvbSB1c2luZyBhbnkgaGV1cmlzdGljIGZvciB0aGUgbnVtYmVyDQo+IG9mIGNvYWxlc2Nl
ZCBkZWxheWVkIEFDSy4NCg0KVGhlcmUgYXJlIHByb2JsZW1zIHdpdGggb25seSBpbXBsZW1lbnRp
bmcgdGhlIGFja3MNCnNwZWNpZmllZCBieSBSRkMxMTIyLg0KDQpJJ3ZlIHNlZW4gcHJvYmxlbXMg
d2hlbiB0aGUgc2VuZGluZyBzaWRlIGlzIGRvaW5nIChJIHRoaW5rKQ0KJ3Nsb3cgc3RhcnQnIHdp
dGggTmFnbGUgZGlzYWJsZWQuDQpUaGUgc2VuZGVyIHdvdWxkIG9ubHkgc2VuZCA0IHNlZ21lbnRz
IGJlZm9yZSB3YWl0aW5nIGZvciBhbg0KQUNLIC0gZXZlbiB3aGVuIGl0IGhhZCBtb3JlIHRoYW4g
YSBmdWxsIHNpemVkIHNlZ21lbnQgd2FpdGluZy4NClNlbmRlciB3YXMgTGludXggMi42LnNvbWV0
aGluZyAocHJvYmFibHkgbG93IDIwcykuDQpJIGNoYW5nZWQgdGhlIGFwcGxpY2F0aW9uIGZsb3cg
dG8gc2VuZCBkYXRhIGluIHRoZSByZXZlcnNlDQpkaXJlY3Rpb24gdG8gYXZvaWQgdGhlIHByb2Js
ZW0uDQpUaGF0IHdhcyBvbiBhIH4wIGRlbGF5IGxvY2FsIGNvbm5lY3Rpb24gLSB3aGljaCBtZWFu
cyB0aGF0DQp0aGVyZSBpcyBhbG1vc3QgbmV2ZXIgb3V0c3RhbmRpbmcgZGF0YSwgYW5kIHRoZSAn
c2xvdyBzdGFydCcNCmhhcHBlbmVkIGFsbW9zdCBhbGwgdGhlIHRpbWUuDQpOYWdsZSBpcyBjb21w
bGV0ZWx5IHRoZSB3cm9uZyBhbGdvcml0aG0gZm9yIHRoZSBkYXRhIGZsb3cuDQoNCglEYXZpZA0K
