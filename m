From: Vaneet Narang <v.narang@samsung.com>
Subject: Re: [PATCH] af_packet: Raw socket destruction warning fix
Date: Fri, 05 Feb 2016 05:23:35 +0000 (GMT)
Message-ID: <1841100414.696991454649811187.JavaMail.weblogic@epmlwas05b>
Reply-To: v.narang@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"willemb@google.com" <willemb@google.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"eyal.birger@gmail.com" <eyal.birger@gmail.com>,
	"tklauser@distanz.ch" <tklauser@distanz.ch>,
	"fruggeri@aristanetworks.com" <fruggeri@aristanetworks.com>,
	"dwmw2@infradead.org" <dwmw2@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>,
	Geon-ho Kim <gh007.kim@samsung.com>,
	Hak-Bong Lee <hakbong5.lee@samsung.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Maninder Singh <maninder1.s@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:58937 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbcBEFYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:24:20 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0O2202OYD70IFU60@mailout4.samsung.com> for
 netdev@vger.kernel.org; Fri, 05 Feb 2016 14:24:18 +0900 (KST)
MIME-version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGksDQoNCj4+DQo+PiBJc3N1ZSBpcyBjb21pbmcgZm9yIDMuMTAuNTguDQo+DQoNClNvcnJ5IGZv
ciBsYXRlIHJlcGx5LCB3ZSB3ZXJlIHRyeWluZyB0byByZXByb2R1Y2UgdGhlIGlzc3VlIGJ1dCBp
dHMgbm90IHRoYXQgZnJlcXVlbnQuDQoNCj5XaGF0IGRyaXZlciBhcmUgeW91IHVzaW5nIChpcyB0
aGF0IGluLXRyZWUpPw0KDQp3ZSBhcmUgZmFjaW5nIGlzc3VlIHdpdGggd2lyZWxlc3MgZHJpdmVy
LiBJcyBpdCBwb3NzaWJsZSB0aGF0IHdpcmVsZXNzIGRyaXZlcg0KY2FuIGNhdXNlIGFueSBpc3N1
ZSBiZWNhdXNlIHJtZW0gYWNjb3VudGluZyBpcyBkb25lIGJ5IGtlcm5lbC4NCg0KPkNhbiB5b3Ug
cmVwcm9kdWNlIHRoZSBzYW1lIGlzc3VlDQo+d2l0aCBhIGxhdGVzdCAtbmV0IGtlcm5lbCwgZm9y
IGV4YW1wbGUgKG9yLCBhICdyZWFzb25hYmx5JyByZWNlbnQgb25lIGxpa2UgNC4zIG9yDQo+NC40
KT8gVGhlcmUgaGFzIGJlZW4gcXVpdGUgYSBiaXQgb2YgY2hhbmdlcyBpbiBlcnIgcXVldWUgaGFu
ZGxpbmcgKHdoaWNoIGFsc28NCj5hY2NvdW50cyBybWVtKSBhcyB3ZWxsLg0KDQpJdCBkaWZmaWN1
bHQgdG8gcG9ydCBvbiA0LjMgYXMgb2Ygbm93IGJ1dCBjYW4geW91IHN1Z2dlc3Qgc29tZSBwYXRj
aGVzIHdoaWNoIGNhbg0KYmUgaGVscGZ1bC4gT25lIG1vcmUgdGhpbmcsIGNhbiBodHRwczovL2xr
bWwub3JnL2xrbWwvMjAxNS85LzE1LzYzNC4gY2hhbmdlIA0KaW4gbGludXgga2VybmVsIGNhdXNl
IHRoaXMgaXNzdWUuIEp1c3QgYW4gb2JzZXJ2YXRpb24gKGNvdWxkIGJlIGluY29ycmVjdCksIGFm
dGVyIA0KaW5jbHVkaW5nIHRoaXMgY2hhbmdlIHdlIGFyZSBmYWNpbmcgdGhpcyBpc3N1ZS4NCg0K
PkhvdyByZWxpYWJseSBjYW4geW91IHRyaWdnZXIgdGhlIGlzc3VlPyBEb2VzIGl0IHRyaWdnZXIN
Cj53aXRoIGEgY29tcGxldGVseSBkaWZmZXJlbnQgaW4tdHJlZSBuZXR3b3JrIGRyaXZlciBhcyB3
ZWxsIHdpdGggeW91ciB0ZXN0cz8NCg0KVGhpcyBpc3N1ZSBpcyBub3QgZWFzaWx5IHJlcHJvZHVj
aWJsZS4gVGhpcyBpc3N1ZSBnZXRzIHJlcHJvZHVjZWQgaW4gbG9uZyB0ZXJtDQp0ZXN0aW5nLiBZ
ZXMgd2lyZWxlc3MgbmV0d29yayBkcml2ZXIgaXMgbm90IGluIHRyZWUuDQoNCj5Xb3VsZCBiZSB1
c2VmdWwgdG8gdHJhY2svZGVidWcgc2tfcm1lbV9hbGxvYyBpbmNyZWFzZXMvZGVjcmVhc2VzIHRv
IHNlZSBmcm9tIHdoaWNoIHBhdGgNCj5uZXcgcm1lbSBpcyBiZWluZyBjaGFyZ2VkIGluIHRoZSB0
aW1lIGJldHdlZW4gcGFja2V0X3JlbGVhc2UoKSBhbmQgcGFja2V0X3NvY2tfZGVzdHJ1Y3QoKQ0K
PmZvciB0aGF0IHNvY2tldCAuLi4NCg0KQXMgaSBtZW50aW9uZWQsIGl0cyBub3QgZWFzaWx5IHJl
cHJvZHVjaWJsZSBidXQgd2UgaGF2ZSBhZGRlZCBzb21lIGRlYnVnIHBhdGNoIGluIA0KcGFja2V0
X3NvY2tfZGVzdHJ1Y3QgdG8gY2hlY2sgdGhlIHZhbHVlIG9mIHJtZW1fYWxsb2MuIA0KU28gYXMg
cGVyIGxvZ3MsIEF0IHRoZSBlbnRyeSBwb2ludCBybWVtX2FsbG9jIHdhcyAwIGJ1dCBhZnRlciBl
cnJvciBxdWV1ZSBwdXJnZSANCml0IGJlY29tZXMgc29tZSA1NzYoc2VlbXMgYSBuZXcgcGFja2V0
IGFkZGVkKS4gTm90IHN1cmUgd2hpY2ggcXVldWUuIA0KSXMgaXQgcG9zc2libGUgdGhhdCBrZXJu
ZWwgY2FuIHN0aWxsIGFkZCBwYWNrZXRzIGluIHJlY2VpdmUgcXVldWUgd2hlbiBzb2NrZXQgaXMg
YWxyZWFkeSBjbG9zZWQsIA0KY2FuIHlvdSBwb2ludCB0aGUga2VybmVsIGNvZGUgd2hlcmUgdGhp
cyBpcyBhdm9pZGVkIG9yIGlzIHRoZXJlIGFueSB3YXkgdGhpcyBnZXRzIGFkZGVkIHRvIGVycm9y
DQpxdWV1ZS4gDQpBcyBwZXIgbXkgdW5kZXJzdGFuZGluZyBybWVtX2FsbG9jIGdldHMgaW5jcmVh
c2VkIG9ubHkgaWYgcGFja2V0cyBnZXRzIGFkZGVkIHRvIHJlY2VpdmUgcXVldWUNCm9yIGVycm9y
IHF1ZXVlLiBJcyBpdCBhbnkgb3RoZXIgcXVldWUgd2hpY2ggYWxzbyBjaGFuZ2VzIHJtZW1fYWxs
b2M/DQoNClRoYW5rcywNClZhbmVldCBOYXJhbmcNCi4uLi4uLi4uLi4uLi4uLi4uLi4uLg==
