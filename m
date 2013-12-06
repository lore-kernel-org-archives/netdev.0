From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tcp: auto corking
Date: Fri, 6 Dec 2013 17:57:44 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7470@saturn3.aculab.com>
References: <1386311765.30495.246.camel@edumazet-glaptop2.roam.corp.google.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7467@saturn3.aculab.com> <52A1F603.2030208@hp.com> <1386351976.30495.266.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: base64
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Rick Jones" <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48106 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751625Ab3LFR6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 12:58:32 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26979-05 for <netdev@vger.kernel.org>;
 Fri,  6 Dec 2013 17:58:28 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1386351976.30495.266.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBXZWxsIHdyaXR0ZW4gYXBwbGljYXRpb25zIHVzZSBUQ1BfQ09SSyBvciBNU0dfTU9SRSwgYnV0
IHVuZm9ydHVuYXRlbHkNCj4gbWFueSBhcHBsaWNhdGlvbnMgYXJlIG5vdCB3ZWxsIHdyaXR0ZW4u
DQoNCklmIHlvdSBrbm93IHlvdSBoYXZlIG11bHRpcGxlIGJ1ZmZlcnMgdG8gc2VuZCwgeW91IGNh
biB1c2Ugd3JpdGV2KCkNCmFuZCBzYXZlIGFsbCB0aGUgc3lzdGVtIGNhbGxzLg0KVGhlIHByb2Js
ZW0gaXMgYXBwbGljYXRpb25zIHRoYXQgZG9uJ3Qga25vdyB0aGF0IHRoZXkgYXJlIGdvaW5nIHRv
DQpoYXZlIG1vcmUgZGF0YSBpbiBhIGZldyBtaWNyb3NlY29uZHMuDQoNCkJ1ZmZlcmluZyBkYXRh
IHVudGlsIHRoZSBza2IgZm9yIGVhcmxpZXIgbWVzc2FnZXMgaGF2ZSBiZWVuIGZyZWVkDQpzZWVt
cyB0byBiZSBoaWdobHkgcmVsaWFudCBvbiB0aGUgbWFjIGRyaXZlciB0YWtpbmcgJ2VuZCBvZiB0
cmFuc21pdCcNCmludGVycnVwdHMgLSBldmVuIG1vcmUgc28gdGhhbiB1c3VhbC4gSSBndWVzcyB0
aGF0IGRyaXZlcnMgb2ZmZXJpbmcNCnNtYWxsIHF1ZXVlIGNvdW50cyBhcmUgZ2VuZXJhdGluZyB0
aG9zZSBpbnRlcnJ1cHRzLg0KDQoJRGF2aWQNCg0K
