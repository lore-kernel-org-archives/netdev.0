From: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Subject: Re: [PATCH net-next v2 1/2] pkt_sched: fq: avoid artificial bursts
 for clocked flows
Date: Wed, 4 Feb 2015 17:56:39 +0000
Message-ID: <2E34EE83-0F64-4CDE-BDE2-4AB59B4D5CF8@ifi.uio.no>
References: <1422992932-9893-1-git-send-email-kennetkl@ifi.uio.no>
 <1423001164.907.43.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out5.uio.no ([129.240.10.17]:36329 "EHLO mail-out5.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966844AbbBDR4o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Feb 2015 12:56:44 -0500
In-Reply-To: <1423001164.907.43.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Content-ID: <8B381E6EF4FFA54AB5131218294FCE0A@mail.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pj4gLQlpZiAodGJbVENBX0ZRX0lOSVRJQUxfUVVBTlRVTV0pDQo+PiAtCQlxLT5pbml0aWFsX3F1
YW50dW0gPSBubGFfZ2V0X3UzMih0YltUQ0FfRlFfSU5JVElBTF9RVUFOVFVNXSk7DQo+PiArCWlm
ICh0YltUQ0FfRlFfSU5JVElBTF9RVUFOVFVNXSkgew0KPj4gKwkJdTMyIGluaXRpYWxfcXVhbnR1
bSA9IG5sYV9nZXRfdTMyKHRiW1RDQV9GUV9JTklUSUFMX1FVQU5UVU1dKTsNCj4+ICsNCj4+ICsJ
CWlmIChpbml0aWFsX3F1YW50dW0gPiBxLT5xdWFudHVtKQ0KPj4gKwkJCXEtPmluaXRpYWxfcXVh
bnR1bSA9IGluaXRpYWxfcXVhbnR1bSAtIHEtPnF1YW50dW07DQo+PiArCQllbHNlDQo+PiArCQkJ
cS0+aW5pdGlhbF9xdWFudHVtID0gMDsNCj4+ICsJfQ0KPiANCj4gUGxlYXNlIGRvIG5vdCBtaXgg
cGF0Y2hlcy4gVGhpcyBwYXJ0IGFscmVhZHkgaGF2ZSBiZWVuIEFja2VkIGJ5IG1lLg0KDQpUaGUg
aGFuZyBmaXggdG91Y2hlcyBhbm90aGVyIHBhcnQgb2YgZnEuIFRoaXMgcGFydCBpcyBzcGVjaWZp
YyB0byB0aGlzIHBhdGNoLg0KDQo+IA0KPiBRdWl0ZSBmcmFua2x5IEkgZG8gbm90IGxpa2UgdGhp
cyBwYXRjaC4NCg0KSWYgaXQgaXMgYSBjb2RlIGlzc3VlLCBwbGVhc2UgcmVmYWN0b3IgaXQgb3Ig
cG9pbnQgb3V0IHNvbWUgc3BlY2lmaWNzLg0KDQpUaGFua3MgZm9yIGNj4oCZaW5nIG1lIG9uIHlv
dXIgcmVsYXRlZCBwYXRjaCAo4oCcZG8gbm90IHBhY2UgcHVyZSBhY2sgcGFja2V0c+KAnSkuIE5v
dGUgdGhhdCB5b3VyIHBhdGNoIGRvZXMgbm90IGFkZHJlc3MgdGhlIGNvcmUgaXNzdWUgdGhhdCB0
aGlzIHBhdGNoIGF0dGVtcHRzIHRvIGZpeDogZnEgdGhyb3R0bGluZyBpcyBqdXN0IGJyb2tlbiBm
b3Igc21hbGwsIGNsb2NrZWQgZmxvd3MuIFRoaXMgbm90IG9ubHkgY29uY2VybnMgVENQL1NDVFAv
QVJRIGFja3MsIGJ1dCBhbHNvIHRoaW4tc3RyZWFtcyBsaWtlIFZvSVAgYW5kIGdhbWluZy4=
