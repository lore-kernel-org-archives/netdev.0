From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 net-next] net: filter: export pkt_type_offset() helper
Date: Thu, 4 Sep 2014 14:23:53 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D174876B4@AcuExch.aculab.com>
References: <1409778511-21273-1-git-send-email-kda@linux-powerpc.org>
	 <54078FBC.5050402@redhat.com>
	 <CAADnVQKNHL7iY=VHp4bs5k2hSDf8jy7H-0H0SgYjb81S25XB9Q@mail.gmail.com>
	 <1409792893.26422.60.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1409793959.3362714.163402573.6A26EDE1@webmail.messagingengine.com>
	 <1409796348.26422.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAADnVQLh6qOD2epUq0S5P8RkUgZA38JNxeP40uBMScLHC2SsJg@mail.gmail.com>
	 <CAHj3AVn8q-JS0Eq0QrfpBo-WfJ+-wXumhNoeDAdkPZC7LSeB5g@mail.gmail.com>
	 <1409831412.23465.3.camel@localhost>
	 <1409836154.26422.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1409838010.23465.16.camel@localhost>
 <1409839892.26422.115.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	"Eric Dumazet" <edumazet@google.com>,
	Denis Kirjanov <kda@linux-powerpc.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Markos Chandras <markos.chandras@imgtec.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55236 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751005AbaIDOZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2014 10:25:07 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17889-09 for <netdev@vger.kernel.org>;
 Thu,  4 Sep 2014 15:25:05 +0100 (BST)
In-Reply-To: <1409839892.26422.115.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRXJpYyBEdW1hemV0DQo+IE9uIFRodSwgMjAxNC0wOS0wNCBhdCAxNTo0MCArMDIwMCwg
SGFubmVzIEZyZWRlcmljIFNvd2Egd3JvdGU6DQo+IA0KPiA+IFRoZSB0eXBlIGRvZXMgbm90IG1h
dHRlciBhdCBhbGwuIEFjdHVhbGx5IEkgd2FudGVkIHRvIHVzZSBhbiBlbXB0eQ0KPiA+IHN0cnVj
dCBidXQgd2FzIGFmcmFpZCBpdCBtaWdodCBub3Qgd29yayBvbiBvbGRlciBjb21waWxlcnMgYW5k
IGRpZG4ndA0KPiA+IHdhbnQgdG8gY2hlY2sgdGhhdCB3aXRoIGVhY2ggdmVyc2lvbi4NCj4gDQo+
IA0KPiBJdCBtYXR0ZXJzLiBSZWFsbHkuDQo+IA0KPiAkIGNhdCB0cnkuYw0KPiAjaW5jbHVkZSA8
c3RkaW8uaD4NCj4gDQo+IHN0cnVjdCBTX2ludCB7DQo+IAljaGFyIGE7DQo+IAlpbnQgb2Zmc2V0
WzBdOw0KPiAJY2hhciBiOjE7DQo+IH07DQo+IA0KPiBzdHJ1Y3QgU19jaGFyIHsNCj4gCWNoYXIg
YTsNCj4gCWNoYXIgb2Zmc2V0WzBdOw0KPiAJY2hhciBiOjE7DQo+IH07DQoNClRob3NlIGFyZSBh
bHNvIGJvdGggaWxsZWdhbCBDLCB6ZXJvIHNpemVkIGFycmF5cyBhcmVuJ3QgYWxsb3dlZC4NCg0K
CURhdmlkDQoNCg==
