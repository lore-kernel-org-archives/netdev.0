From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v7] bfin_mac: convert bfin Ethernet driver to NAPI
 framework
Date: Tue, 22 Jul 2014 09:10:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1727AF5D@AcuExch.aculab.com>
References: <1406014682-19188-1-git-send-email-sonic.adi@gmail.com>
	<1406015984.10255.121.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140722.010105.2036198226851589509.davem@davemloft.net>
 <CAJxxZ0Niah8QXGoa4CT4Y5i7qnSjL2xq_GYq7rUHmdJpaNzBHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"adi-buildroot-devel@lists.sourceforge.net"
	<adi-buildroot-devel@lists.sourceforge.net>,
	"Zhang, Sonic" <sonic.zhang@analog.com>
To: 'Sonic Zhang' <sonic.adi@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37915 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752802AbaGVJLZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 05:11:25 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08472-09 for <netdev@vger.kernel.org>;
 Tue, 22 Jul 2014 10:11:16 +0100 (BST)
In-Reply-To: <CAJxxZ0Niah8QXGoa4CT4Y5i7qnSjL2xq_GYq7rUHmdJpaNzBHg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogU29uaWMgWmhhbmcNCi4uLg0KPiBpZiAoIS0tQSkNCj4gDQo+IGRvZXNuJ3QgZXF1YWwg
dG8NCj4gDQo+IGlmIChBLS0pDQo+ICAgICAgICAgaWYgKCFBKQ0KPiANCj4gSW4gbmV0IHBvbGwg
bG9vcCwgYmVjYXVzZSBvZiBOQVBJIHN0YXRlIGJpdCBOQVBJX1NUQVRFX05QU1ZDLCB0aGUgbmFw
aQ0KPiBwb2xsIGNhbGxiYWNrIG1heSBiZSBjYWxsZWQgd2l0aCBBID0gMCAoTUFDIFJYIElSUSBp
cyBlbmFibGVkKSBpZg0KPiBuYXBpX2NvbXBsZXRlKCkgb3RoZXIgdGhhbiBfX25hcGlfY29tcGxl
dGUoKSBpcyB1c2VkLiBTZWUgdGhlDQo+IGV4cGxhbmF0aW9uIGluIG15IGxhc3QgZW1haWwuDQo+
IA0KPiBJbiB0aGlzIGNhc2UsIHRoZSB1cCBjb25kaXRpb24gZGVjcmVhc2VzIEEgdG8gYSBuZWdh
dGl2ZSBudW1iZXIgYW5kDQo+IHRoZSBpbnRlcnJ1cHQgaGFuZGxlciBjb25kaXRpb24gImlmICgh
QSsrKSIgY2FuIG5ldmVyIGluY3JlYXNlIEEgYmFjaw0KPiB0byAwIChkaXNhYmxlIHRoZSBSWCBJ
UlEpLiBXaGlsZSwgdGhlIGRvd24gY29uZGl0aW9uIG9ubHkgZGVjcmVhc2VzIEENCj4gaWYgaXQg
aXMgbm90IDAuDQoNClRoZSBsb2dpYyBkb2Vzbid0IG1hdHRlciwgdGhlIEMgaXMgZXF1aXZhbGVu
dCAtIHRoZSBjb21waWxlciBwcm9iYWJseQ0KZ2VuZXJhdGVzIHRoZSBzYW1lIGNvZGUuDQpUaGUg
b25seSB0aW1lIHRoZXkgbWlnaHQgYmUgZGlmZmVyZW50IGlzIGlmICdBJyBpcyB2b2xhdGlsZS4N
CldlbGwsIGFwYXJ0IGZyb20gdGhlIG5vbi1kZXRlcm1pbmlzdGljIGNhc2VzIHdoZXJlIG90aGVy
IGNvZGUgaXMNCm1vZGlmeWluZyB0aGUgdmFyaWFibGUgYXQgdGhlIHNhbWUgdGltZSAtIGFuZCB5
b3UgYXJlIGF0IHRoZSB3aGltDQpvZiB0aGUgY29tcGlsZXIuDQoNCglEYXZpZA0KDQo=
