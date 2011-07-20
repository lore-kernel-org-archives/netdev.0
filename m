From: "Loke, Chetan" <Chetan.Loke@netscout.com>
Subject: RE: [PATCH] pktgen: Clone skb to avoid corruption of skbs in ndo_start_xmit methods
Date: Wed, 20 Jul 2011 11:17:01 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B912AC4058@nsmail.netscout.com>
References: <1311105179-26408-1-git-send-email-nhorman@tuxdriver.com> <1311105738.3113.11.camel@edumazet-laptop> <20110719202922.GA2352@minipsycho> <1311108107.3113.22.camel@edumazet-laptop> <20110720001904.GA1992@neilslaptop.think-freely.org> <1311122593.3113.46.camel@edumazet-laptop> <4E2626E1.6030005@candelatech.com> <20110720020737.GB2692@neilslaptop.think-freely.org> <1311135855.3113.66.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Ben Greear" <greearb@candelatech.com>,
	"Jiri Pirko" <jpirko@redhat.com>, <netdev@vger.kernel.org>,
	"Alexey Dobriyan" <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Eric Dumazet" <eric.dumazet@gmail.com>,
	"Neil Horman" <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod6og109.obsmtp.com ([64.18.1.23]:54136 "HELO
	exprod6og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751006Ab1GTPRN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jul 2011 11:17:13 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1311135855.3113.66.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+IFNvIHdoZW4gSSBzYWlkICJyZW1vdmUgcGt0Z2VuIiBmcm9tIGRpc3RybyBpdCB3YXMgbm90
IGEgam9rZS4NCj4gTWF5YmUgaXRzIHRpbWUgdG8gYWRtaXQgcGt0Z2VuIGhhcyB0byBiZSByZW1v
dmVkIGZyb20ga2VybmVsIHNvdXJjZXMuDQo+IA0KDQpQbGVhc2UsIGxldCdzIG5vdCByZW1vdmUg
cGt0Z2VuIGZyb20ga2VybmVsIHNvdXJjZXMuIFdlIGNhbiBhZGQgYSBDT05GSUdfUEtUR0VOIGFz
IHNvbWVvbmUgbWVudGlvbmVkIGluIHRoZSBlbWFpbCB0aHJlYWQuDQoNCg0KPiAkIHdjIG5ldC9j
b3JlL3BrdGdlbi5jDQo+ICAzNzg4IDEwODgxIDkyNzcxIG5ldC9jb3JlL3BrdGdlbi5jDQo+IA0K
PiBIbW1tLCAzNzg4IGxpbmVzLCBwYXRjaGVkIDE4MCB0aW1lcyBmb3IgYSB0aGluZyB0aGF0IG9u
bHkgc2VuZHMgVURQDQo+IGZyYW1lcy4uLg0KDQpJdCByZWFsbHkgZG9lc24ndCBtYXR0ZXIgd2hh
dCB0cmFmZmljIGl0IHNlbmRzLiBBcyBsb25nIGFzIEkgY2FuIGdldCBzb21lIGhpZ2ggc3BlZWQg
dGhyb3VnaHB1dCBJIGFtIGdvb2QuDQpUaGVyZSBhcmUgcXVpdGUgYSBmZXcgdXNlLWNhc2VzIHdo
ZXJlIG9uZSBkb2Vzbid0IHJlYWxseSBuZWVkIHRvIGtub3cgdGhlIHRyYWZmaWMgcHJvZmlsZS4N
Cg==
