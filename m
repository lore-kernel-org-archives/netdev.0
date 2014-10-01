From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: How exactly does CHECKSUM_COMPLETE works?
Date: Wed, 1 Oct 2014 05:17:27 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63B417B6@avmb3.qlogic.org>
References: <B5657A6538887040AD3A81F1008BEC63B41317@avmb3.qlogic.org>
	<CA+mtBx_17aJuK=xjnDukGJOfw-twHg=rF5rDacg6pga6ZTTRcw@mail.gmail.com>
	<B5657A6538887040AD3A81F1008BEC63B4152D@avmb3.qlogic.org>
	<1412104977.30721.94.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412105832.30721.95.camel@edumazet-glaptop2.roam.corp.google.com>
	<B5657A6538887040AD3A81F1008BEC63B4159B@avmb3.qlogic.org>
	<B5657A6538887040AD3A81F1008BEC63B415CB@avmb3.qlogic.org>
 <CA+mtBx8mt5qez5X5tPF_3S+0p2svmLScmxBvXziBYT9XTJ+w0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: "Tom Herbert (Partner - google)" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:59187 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139AbaJAFRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 01:17:34 -0400
In-Reply-To: <CA+mtBx8mt5qez5X5tPF_3S+0p2svmLScmxBvXziBYT9XTJ+w0w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+IE9yIGxvb2tpbmcgYmFjayBvbiB0aGUgSVB2NC9UQ1Agc2NlbmFyaW8sIHdoYXQgZXhhY3Rs
eSBpcyB0aGUgY3N1bSBub3cNCj4gPiBwcm90ZWN0aW5nPw0KPiA+IEFzc3VtZSB0aGUgSFcgcGFz
c2VzIHRoZSBvbmUncyBjb21wbGVtZW50IHN1bSBvZiB0aGUgZW50aXJlIGRhdGEsIElQDQo+ID4g
aGVhZGVyIGFuZCBvbndhcmQgdG8gZHJpdmVyLCB3aGljaCBzZXRzIGl0IGluIFNLQi0+Y3N1bSBh
bmQgbWFya3MgdGhlDQo+ID4gU0tCIGFzIENIRUNLU1VNX0NPTVBMRVRFLg0KPiA+IEluIHByYWN0
aWNlLCBTS0ItPmNzdW0gc2hvdWxkIG5vdyBlcXVhbCB0byB0aGUgb25lJ3MgY29tcGxlbWVudCBv
ZiB0aGUNCj4gPiBUQ1AgcHNldWRvIGhlYWRlcjsgQnV0IG90aGVyIHRoYW4gdGhlIGxlbmd0aCBv
ZiBkYXRhIGluIHRoZSBUQ1AgaGVhZGVyDQo+ID4gYW5kIHBheWxvYWQgdGhhdCBwc2V1ZG8taGVh
ZGVyIGRvZXNuJ3QgaW5jbHVkZSBhbnkgaW5mb3JtYXRpb24gYWJvdXQNCj4gPiB0aGUgcGF5bG9h
ZCBpdHNlbGYuDQo+IA0KPiBCdXQgaXQgZG9lcywgYXMgeW91IHBvaW50ZWQgb3V0IHRoZSBjaGVj
a3N1bSBjYWxjdWxhdGlvbiB3YXMgcGVyZm9ybWVkIG92ZXINCj4gdGhlIHdob2xlIHBheWxvYWQu
IFRoZSBmYWN0IHRoYXQgdGhlIGNvbXB1dGVkIGNoZWNrc3VtIGVxdWFscyB0aGUgb25lJ3MNCj4g
Y29tcGxlbWVudCBvZiBwc2V1ZG8gaGVhZGVyIGlzIHRoZSBpbmRpY2F0aW9uIHRoYXQgdGhlIGNo
ZWNrc3VtIGlzIHZhbGlkLiBJZg0KPiB0aGVyZSB3ZXJlIGEgYml0IGNvcnJ1cHRpb24sIHRoZSBj
b21wdXRlZCB2YWx1ZSB3b3VsZCBiZSBkaWZmZXJlbnQgKHN1bW1pbmcgaW4NCj4gcHNldWRvIGhl
YWRlciBjaGVja3N1bSB3b3VsZCByZXN1bHQgaW4gbm9uLXplcm8gdmFsdWUpLg0KDQpUaGFua3Ms
IEkndmUgYWxyZWFkeSByZWFjaGVkIHRoYXQgY29uY2x1c2lvbiBteXNlbGYNCltldmVuIHdyb3Rl
IGFuIEUtbWFpbDsgYnV0IGl0IGdvdCBibG9ja2VkIGZvciBzb21lIHJlYXNvbl0uDQoNCg==
