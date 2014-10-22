From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH] net: fix saving TX flow hash in sock for outgoing
 connections
Date: Wed, 22 Oct 2014 18:35:59 +0000
Message-ID: <CF9D1877D81D214CB0CA0669EFAE020C68CA2FAA@CMEXMB1.ad.emulex.com>
References: <1413994321-20435-1-git-send-email-sathya.perla@emulex.com>
 <1413999542.9031.13.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"therbert@google.com" <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:29485 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbaJVSgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 14:36:32 -0400
In-Reply-To: <1413999542.9031.13.camel@edumazet-glaptop2.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBFcmljIER1bWF6ZXQgW21haWx0
bzplcmljLmR1bWF6ZXRAZ21haWwuY29tXQ0KPiANCj4gT24gV2VkLCAyMDE0LTEwLTIyIGF0IDIx
OjQyICswNTMwLCBTYXRoeWEgUGVybGEgd3JvdGU6DQo+ID4gVGhlIGNvbW1pdCAibmV0OiBTYXZl
IFRYIGZsb3cgaGFzaCBpbiBzb2NrIGFuZCBzZXQgaW4gc2tidWYgb24geG1pdCINCj4gPiBpbnRy
b2R1Y2VkIHRoZSBpbmV0X3NldF90eGhhc2goKSBhbmQgaXA2X3NldF90eGhhc2goKSByb3V0aW5l
cyB0bw0KPiBjYWxjdWxhdGUNCj4gPiBhbmQgcmVjb3JkIGZsb3cgaGFzaChza190eGhhc2gpIGlu
IHRoZSBzb2NrZXQgc3RydWN0dXJlLiBza190eGhhc2ggaXMgdXNlZA0KPiA+IHRvIHNldCBza2It
Pmhhc2ggd2hpY2ggaXMgdXNlZCB0byBzcHJlYWQgZmxvd3MgYWNyb3NzIG11bHRpcGxlIFRYUXMu
DQo+ID4NCj4gPiBCdXQsIHRoZSBhYm92ZSByb3V0aW5lcyBhcmUgaW52b2tlZCBiZWZvcmUgdGhl
IHNvdXJjZSBwb3J0IG9mIHRoZQ0KPiBjb25uZWN0aW9uDQo+ID4gaXMgY3JlYXRlZC4gQmVjYXVz
ZSBvZiB0aGlzIGFsbCBvdXRnb2luZyBjb25uZWN0aW9ucyB0aGF0IGp1c3QgZGlmZmVyIGluIHRo
ZQ0KPiA+IHNvdXJjZSBwb3J0IGdldCBoYXNoZWQgaW50byB0aGUgc2FtZSBUWFEuDQo+IA0KPiBB
Y2tlZC1ieTogRXJpYyBEdW1hemV0IDxlZHVtYXpldEBnb29nbGUuY29tPg0KPiANCj4gQXJlIHlv
dSByZWFsbHkgdXNpbmcgdGhlIHNvY2tldC9mbG93IGhhc2ggdG8gc2VsZWN0IGEgVFhRID8NClll
cywgYXMgSSBkb24ndCBoYXZlIFhQUyBjb25maWd1cmVkIG9uIG15IHNldHVwLg0KbmV0ZGV2X3Bp
Y2tfdHgoKSB1c2VzIHRoZSBzb2NrZXQvZmxvdyBoYXNoIHdoZW4gWFBTIGlzIG5vdCB1c2VkLg0K
DQo+IA0KPiBFdmVuIHdpdGggdGhpcyBwYXRjaCwgeW91IGhhdmUgYSBnb29kIHByb2JhYmlsaXR5
IG9mIG11bHRpcGxlDQo+IGNwdXMgaGl0dGluZyBzYW1lIFRYUS4NCkFncmVlLiBBcmUgeW91IHN1
Z2dlc3RpbmcgdGhhdCBkcml2ZXJzIHNob3VsZCBhdXRvbWF0aWNhbGx5DQpyZWdpc3RlciBhbiBY
UFMgY29uZmlndXJhdGlvbj8gSSB0aG91Z2h0IGl0IHdhcyB1cHRvIHRoZSB1c2VyDQp0byBlbmFi
bGUgaXQuLi4NCg==
