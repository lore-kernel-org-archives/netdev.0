From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] net: sched: use no more than one page in
 struct fw_head
Date: Mon, 17 Mar 2014 15:43:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6DF5AE@AcuExch.aculab.com>
References: <1394744203.21721.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140313211509.GP21124@linux.vnet.ibm.com> <53229704.1040808@gmail.com>
	 <20140314132834.GS21124@linux.vnet.ibm.com>
	 <1394804798.21721.64.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140314153810.GX21124@linux.vnet.ibm.com>
	 <20140314185005.GA17041@linux.vnet.ibm.com>
	 <20140314185917.GA18933@linux.vnet.ibm.com>
	 <1394826958.9668.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1394985990.9668.26.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140317135101.GA8956@casper.infradead.org>
	 <1395065631.9668.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <063D6719AE5E284EB5DD2968C1650D6D0F6DF4C4@AcuExch.aculab.com>
 <1395069365.9668.49.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	"John Fastabend" <john.fastabend@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:45466 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932575AbaCQPoh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2014 11:44:37 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 10415-06 for <netdev@vger.kernel.org>;
 Mon, 17 Mar 2014 15:44:35 +0000 (GMT)
In-Reply-To: <1395069365.9668.49.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0IC4uLg0KPiA+IG9yIHVzZSBhICdtb2R1bG8gMl5uLTEgcmVkdWN0
aW9uJzoNCj4gPiAJaGFuZGxlID0gKGhhbmRsZSAmIDB4M2ZmZmYpICsgKGhhbmRsZSA+PiAxOCk7
DQo+ID4gCWRvDQo+ID4gCQloYW5kbGUgPSAoaGFuZGxlICYgMHgxZmYpICsgKGhhbmRsZSA+PiA5
KTsNCj4gPiAJd2hpbGUgKGhhbmRsZSA+IDB4MWZmdSk7DQo+IA0KPiBBbGwgdGhlc2UgdHJpY2tz
IHdlcmUgbmVlZGVkIDIwIHllYXJzIGFnby4NCj4gDQo+IEV2ZW4gVGhvbWFzIGxhcHRvcCBjYW4g
ZG8gYSBkaXZpZGUgZmFzdGVyIHRoYW4gdGhpcyBsb29wLg0KDQpUaGUgbmlvcyBjcHUgb24gbXkg
ZnBnYSBjYW4ndCA6LSkNCk9UT0ggSSB3b3VsZG4ndCBydW4gTGludXggb24gYSAxMDBNaHogY3B1
Lg0KDQoJRGF2aWQNCg0KDQo=
