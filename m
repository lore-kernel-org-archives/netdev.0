From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] xen-netback: disable rogue vif in kthread context
Date: Mon, 24 Mar 2014 12:33:18 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6E784F@AcuExch.aculab.com>
References: <1395663214-14133-1-git-send-email-wei.liu2@citrix.com>
 <1395663724.6294.18.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>,
	"zoltan.kiss@citrix.com" <zoltan.kiss@citrix.com>,
	"edwin@etorok.net" <edwin@etorok.net>
To: 'Ian Campbell' <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59529 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752622AbaCXMd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Mar 2014 08:33:56 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 09013-06 for <netdev@vger.kernel.org>;
 Mon, 24 Mar 2014 12:33:53 +0000 (GMT)
In-Reply-To: <1395663724.6294.18.camel@kazak.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSWFuIENhbXBiZWxsDQouLi4NCj4gPiArCQlpZiAodW5saWtlbHkodmlmLT5kaXNhYmxl
ZCkgJiYgbmV0aWZfY2Fycmllcl9vayh2aWYtPmRldikpDQo+IA0KPiBQZXJoYXBzIGNvbnNpZGVy
IGV4dGVuZGluZyB0aGUgc2NvcGUgb2YgdGhlIHVubGlrZWx5IG92ZXIgdGhlIGVudGlyZQ0KPiBl
eHByZXNzaW9uPyAobm90IHRoYXQgSSBleHBlY3QgaXQgd2lsbCBtYXR0ZXIgbXVjaCkNCg0KQSBs
b3Qgb2YgdGhlc2UgJ3VubGlrZWx5JyBhcmUgYXMgbXVjaCBhIGhpbnQgdG8gdGhlIHBlcnNvbg0K
cmVhZGluZyB0aGUgY29kZSB0aGFuIHRvIHRoZSBjb21waWxlciENCg0KSSBmb3VuZCAod2l0aCBh
IG11Y2ggb2xkZXIgZ2NjKSB0aGF0IGFuIG92ZXJhbGwgJ3VubGlrZWx5JyBkaWRuJ3QNCmhhdmUg
dGhlIHNhbWUgZWZmZWN0IGFzIG9uZSBvbiBlYWNoIHBhcnQuDQpJIGFsc28gZm91bmQgdGhhdCBn
Y2MgaWdub3JlZCAndW5saWtlbHknIGlmIHRoZSAnZWxzZScgYnJhbmNoIGlzIGVtcHR5Lg0KDQon
aWYgKHVubGlrZWx5KC4uLikpIGNvbnRpbnVlJyBnZW5lcmF0ZWQgYSBiYWNrd2FyZHMgKHByZWRp
Y3RlZCB0cnVlKQ0KY29uZGl0aW9uYWwgYnJhbmNoLiBJIGFkZGVkIGFuIGFzbSgiY29tbWVudCAi
ICMjIF9fTElORV9fKSBiZWZvcmUNCnRoZSBjb250aW51ZSB0byBmb3JjZSBhIGZvcndhcmRzIGNv
bmRpdGlvbiBicmFuY2ggdG8gYW4gdW5jb25kaXRpb25hbA0KYnJhbmNoIHRvIHRoZSBsb29wIHRv
cC4NCihZZXMgLSBJIGRpZCBjYXJlIGFib3V0IGV2ZXJ5IGNsb2NrIGluIHRoYXQgY29kZS4pDQoN
CglEYXZpZA0KDQo=
