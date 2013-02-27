From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sctp: Validate parameter size for
 SCTP_GET_ASSOC_STATS control message
Date: Wed, 27 Feb 2013 15:33:44 -0500 (EST)
Message-ID: <20130227.153344.2178498124458359369.davem@davemloft.net>
References: <1361994231-5355-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	vyasevich@gmail.com, sri@us.ibm.com, nhorman@tuxdriver.com
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754507Ab3B0Udq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 15:33:46 -0500
In-Reply-To: <1361994231-5355-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogR3VlbnRlciBSb2VjayA8bGludXhAcm9lY2stdXMubmV0Pg0KRGF0ZTogV2VkLCAyNyBG
ZWIgMjAxMyAxMTo0Mzo1MSAtMDgwMA0KDQo+IEJ1aWxkaW5nIHNjdHAgbWF5IGZhaWwgd2l0aDoN
Cj4gDQo+IEluIGZ1bmN0aW9uIKFjb3B5X2Zyb21fdXNlcqIsDQo+ICAgICBpbmxpbmVkIGZyb20g
oXNjdHBfZ2V0c29ja29wdF9hc3NvY19zdGF0c6IgYXQNCj4gICAgIG5ldC9zY3RwL3NvY2tldC5j
OjU2NTY6MjA6DQo+IGFyY2gveDg2L2luY2x1ZGUvYXNtL3VhY2Nlc3NfMzIuaDoyMTE6MjY6IGVy
cm9yOiBjYWxsIHRvDQo+ICAgICChY29weV9mcm9tX3VzZXJfb3ZlcmZsb3eiIGRlY2xhcmVkIHdp
dGggYXR0cmlidXRlIGVycm9yOiBjb3B5X2Zyb21fdXNlcigpDQo+ICAgICBidWZmZXIgc2l6ZSBp
cyBub3QgcHJvdmFibHkgY29ycmVjdA0KPiANCj4gaWYgYnVpbHQgd2l0aCBXPTEgZHVlIHRvIGEg
bWlzc2luZyBwYXJhbWV0ZXIgc2l6ZSB2YWxpZGF0aW9uLg0KPiANCj4gU2lnbmVkLW9mZi1ieTog
R3VlbnRlciBSb2VjayA8bGludXhAcm9lY2stdXMubmV0Pg0KDQpUaGlzIGNoYW5nZSBpcyBjb3Jy
ZWN0LCBidXQgcGxlYXNlIGZpeCB0aGlzIGJ5IHNpbXBseSBtb3ZpbmcgdGhlOg0KDQoJLyogQWxs
b3cgdGhlIHN0cnVjdCB0byBncm93IGFuZCBmaWxsIGluIGFzIG11Y2ggYXMgcG9zc2libGUgKi8N
CglsZW4gPSBtaW5fdChzaXplX3QsIGxlbiwgc2l6ZW9mKHNhcykpOw0KDQpsaW5lIGhpZ2hlciB1
cCBpbiB0aGUgZnVuY3Rpb24uDQoNCkFuZCBJIGFsc28gcHJlZmVyIHRoaXMgYmVjYXVzZToNCg0K
CXNvbWV0aGluZyB0ZXN0aW5nIHNpemVvZihmb28pOw0KCWlmIChjb3B5X2Zyb21fdXNlciguLi4s
IC4uLiwgc2l6ZW9mKGZvbykpKQ0KDQptdXN0IGVhc2llciB0byBhdWRpdCBhbmQgdmFsaWRhdGUs
IGVzcGVjaWFsbHkgaW4gcGF0Y2ggZm9ybS4NCg0KT3RoZXJ3aXNlIEkgaGF2ZSB0byBicmluZyB0
aGUgY29kZSBpbnRvIGFuIGVkaXRvciBhbmQgcmVhZCB0aGUgd2hvbGUNCmZ1bmN0aW9uIGp1c3Qg
dG8gbWFrZSBzdXJlIHlvdSBnb3QgdGhlIHR5cGUgY29ycmVjdC4NCg0KVGhhbmtzLg0K
