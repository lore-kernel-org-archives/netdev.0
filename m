From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net-next 03/12] i40e: Handle a single mss packet with more
 than 8 frags
Date: Mon, 17 Nov 2014 14:40:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9F1E87@AcuExch.aculab.com>
References: <1416031715-32498-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416031715-32498-4-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1416075695.17262.86.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9F1E54@AcuExch.aculab.com>
 <1416234687.5102.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Serey Kong <serey.kong@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Shannon Nelson <shannon.nelson@intel.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50229 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752419AbaKQOli (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 09:41:38 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 04842-05 for <netdev@vger.kernel.org>;
 Mon, 17 Nov 2014 14:41:28 +0000 (GMT)
In-Reply-To: <1416234687.5102.2.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyANCj4gT24gTW9uLCAyMDE0LTExLTE3IGF0IDE0OjE1ICswMDAwLCBEYXZpZCBM
YWlnaHQgd3JvdGU6DQo+IA0KPiA+IERpZG4ndCBzb21lb25lIHdyaXRlIGEgZnVuY3Rpb24gdGhh
dCBzaWduaWZpY2FudGx5IHJlZHVjZXMgdGhlDQo+ID4gbnVtYmVyIG9mIGZyYWdtZW50cyB3aXRo
b3V0IGFjdHVhbGx5IHJlcXVpcmluZyBhIHNpbmdsZSBsaW5lYXIgYmxvY2s/DQo+IA0KPiBJIHBy
ZXN1bWUgeW91IHJlZmVyIHRvIGFsbG9jX3NrYl93aXRoX2ZyYWdzKCkgOiBJdCBkb2VzIHRoZSBh
bGxvY2F0aW9uLA0KPiBidXQgSSB3YXMgZXhwZWN0aW5nIHNvbWUga2luZCBzb3VsIHRvIGNvbnRp
bnVlIG15IHdvcmsgYW5kIHByb3ZpZGUgdGhlDQo+IGNvbXBhbmlvbiBjb2RlIHRvIGRvIHRoZSBj
b3B5Lg0KDQpOb3QgdGhhdCBvbmUuDQpJSVJDIGlzIHdhcyBkb25lIHRvIHJlZHVjZSB0aGUgbnVt
YmVyIG9mIGZyYWdtZW50cyB0aHJvdWdoIHhlbm5ldC4NCg0KWW91IHJlYWxseSB3YW50IHRvIHRy
eSB0byBrZWVwIHNvbWUgb2YgdGhlIG9sZCBmcmFnbWVudHMsIGp1c3QgYWRkaW5nDQpuZXcgb25l
cyB0byBtZXJnZSBzaG9ydCBzZWN0aW9ucy4NCg0KT1RPSCA4IGZyYWdtZW50cyBpc24ndCBlbm91
Z2ggaWYgdGhlIE1BQyBzdXBwb3J0cyBUU08gKGR1bm5vIGlmIGl0IGRvZXMpLg0KVGhlIHNrYl9s
aW5lYXJpemUoKSBpcyBvbmx5IGxpa2VseSB0byBmYWlsIGZvciBUU08gYW55d2F5Lg0KT3IgcmF0
aGVyLCBpZiBpdCBjYW4ndCBhbGxvY2F0ZSBhIDRrIHBhZ2UgeW91IGFyZSBhbHJlYWR5IHN0dWZm
ZWQuDQoNCglEYXZpZC4NCg0K
