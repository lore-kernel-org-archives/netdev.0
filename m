From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 09:11:09 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543FFC03.1060207@redhat.com>
 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
 <54400C6C.7010405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: 'Alexander Duyck' <alexander.h.duyck@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50994 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750807AbaJQJMt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Oct 2014 05:12:49 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22274-10 for <netdev@vger.kernel.org>;
 Fri, 17 Oct 2014 10:12:40 +0100 (BST)
In-Reply-To: <54400C6C.7010405@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGFuZGVyIER1eWNrDQouLi4NCj4gQWN0dWFsbHkgdGhlIGxpa2VsaWhvb2Qgb2Yg
YW55dGhpbmcgaG9sZGluZyBvbnRvIHRoZSA0SyBwYWdlIGZvciB2ZXJ5DQo+IGxvbmcgZG9lc24n
dCBzZWVtIHRvIG9jY3VyLCBhdCBsZWFzdCBmcm9tIHRoZSBkcml2ZXJzIHBlcnNwZWN0aXZlLiAg
SXQNCj4gaXMgb25lIG9mIHRoZSByZWFzb25zIHdoeSBJIHdlbnQgZm9yIHRoZSBwYWdlIHJldXNl
IGFwcHJvYWNoIHJhdGhlciB0aGFuDQo+IGp1c3QgcGFydGl0aW9uaW5nIGEgc2luZ2xlIGxhcmdl
IHBhZ2UuICBJdCBhbGxvd3MgdXMgdG8gYXZvaWQgaGF2aW5nIHRvDQo+IGNhbGwgSU9NTVUgbWFw
L3VubWFwIGZvciB0aGUgcGFnZXMgc2luY2UgdGhlIGVudGlyZSBwYWdlIGlzIHVzdWFsbHkgYmFj
aw0KPiBpbiB0aGUgZHJpdmVyIG93bmVyc2hpcCBiZWZvcmUgd2UgbmVlZCB0byByZXVzZSB0aGUg
cG9ydGlvbiBnaXZlbiB0byB0aGUNCj4gc3RhY2suDQoNClRoYXQgaXMgYWxtb3N0IGNlcnRhaW5s
eSB0cnVlIGZvciBtb3N0IGJlbmNobWFya3MsIGJlbmNobWFyayBwcm9jZXNzZXMNCmNvbnN1bWUg
cmVjZWl2ZSBkYXRhLg0KQnV0IHdoYXQgYWJvdXQgcmVhbCBsaWZlIHNpdHVhdGlvbnM/DQoNClRo
ZXJlIG11c3QgYmUgc29tZSAnbm9ybWFsJyB3b3JrbG9hZHMgd2hlcmUgcmVjZWl2ZSBkYXRhIGRv
ZXNuJ3QgZ2V0IGNvbnN1bWVkLg0KDQoJRGF2aWQNCg0K
