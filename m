From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Sun, 26 Jun 2016 06:09:05 +0000
Message-ID: <CO2PR11MB0088DAA03A253929FF0F32DA97200@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <576B08A2.8080603@hpe.com>
 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
 <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uex41aBJX84we2gxNGw6M4s5xGEPnDkGehTZkEE+i+Jhw@mail.gmail.com>
 <CO2PR11MB0088B3C577EC110B845C17B3972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CO2PR11MB0088949623FA99ED86D33205972D0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc7cCu-5SwrB+4Mv6OM+V1jDwefOoG-Wr61C4F1g1BmFA@mail.gmail.com>
 <058fd87e-4dbe-f80e-0606-508956f339a7@solarflare.com>
 <CALx6S341Pb-fq+trudZDOY3SpFzJvyqhrTGQd+7t0hDc3Jr_ig@mail.gmail.com>
 <9834a2dd-33c0-33b1-697e-49a39b1b7554@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rick Jones <rick.jones2@hpe.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"Hannes Frederic Sowa" <hannes@redhat.com>,
	Bert Kenward <bkenward@solarflare.com>
To: Edward Cree <ecree@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0123.outbound.protection.outlook.com ([65.55.169.123]:18823
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751630AbcFZGJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jun 2016 02:09:09 -0400
In-Reply-To: <9834a2dd-33c0-33b1-697e-49a39b1b7554@solarflare.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGdW5kYW1lbnRhbGx5IEkgYmVsaWV2ZSB0aGF0IHJvYnVzdCwgcmVzcG9uc2l2ZSBoYXJkd2Fy
ZSBMUk8gaXMgbm90IHdvcmthYmxlIGFzDQo+IHRoZSBoYXJkd2FyZSB3b3VsZCBoYXZlIHRvIGRl
Y2lkZSB0byBob2xkIG9udG8gcGFja2V0cyBpbiB0aGUgaG9wZSBvZiBtZXJnZQ0KPiBjYW5kaWRh
dGVzIGFycml2aW5nIHNvb24gYWZ0ZXIuICBXaGVyZWFzIGluIHRoZSBzb2Z0d2FyZSBsYXllciAo
R1JPLA0KPiBidW5kbGluZy4uLiksIHRoZSBwYWNrZXRzIGFyZSBhbHJlYWR5IGNvbWluZyBpbiBi
dXJzdHMgdGhhbmtzIHRvIHRoZSB3YXkgbmFwaQ0KPiBwb2xsaW5nIGJlaGF2ZXMuDQoNClNvdW5k
cyBsaWtlIGFuIGFkZGl0aW9uYWwgY29hbGVzY2luZyBjb25maWd1cmF0aW9uIHRvIG1lIFthc3N1
bWluZyBIVyBzdXBwb3J0cyBpdF0uDQo=
