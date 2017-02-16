From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v7 2/2] qede: Add driver support for PTP
Date: Thu, 16 Feb 2017 12:38:19 +0000
Message-ID: <BL2PR07MB2306CD2B1CFECEE4AAB425108D5A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1487147051-14350-1-git-send-email-Yuval.Mintz@cavium.com>
         <1487147051-14350-3-git-send-email-Yuval.Mintz@cavium.com>
 <1487247814.1311.34.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0081.outbound.protection.outlook.com ([104.47.34.81]:39104
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753434AbdBPMiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:38:25 -0500
In-Reply-To: <1487247814.1311.34.camel@edumazet-glaptop3.roam.corp.google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiA+ICt2b2lkIHFlZGVfcHRwX3R4X3RzKHN0cnVjdCBxZWRlX2RldiAqZWRldiwgc3RydWN0IHNr
X2J1ZmYgKnNrYikgew0KPiA+ICsJc3RydWN0IHFlZGVfcHRwICpwdHA7DQo+ID4gKw0KPiA+ICsJ
cHRwID0gZWRldi0+cHRwOw0KPiA+ICsJaWYgKCFwdHApDQo+ID4gKwkJcmV0dXJuOw0KPiA+ICsN
Cj4gPiArCWlmICh1bmxpa2VseSghKGVkZXYtPmZsYWdzICYgUUVERV9UWF9USU1FU1RBTVBJTkdf
RU4pKSkgew0KPiA+ICsJCURQX05PVElDRShlZGV2LA0KPiA+ICsJCQkgICJUeCB0aW1lc3RhbXBp
bmcgd2FzIG5vdCBlbmFibGVkLCB0aGlzIHBhY2tldCB3aWxsDQo+IG5vdCBiZSB0aW1lc3RhbXBl
ZFxuIik7DQo+ID4gKwl9IGVsc2UgaWYgKHVubGlrZWx5KHB0cC0+dHhfc2tiKSkgew0KPiA+ICsJ
CURQX05PVElDRShlZGV2LA0KPiA+ICsJCQkgICJUaGUgZGV2aWNlIHN1cHBvcnRzIG9ubHkgYSBz
aW5nbGUgb3V0c3RhbmRpbmcNCj4gcGFja2V0IHRvIHRpbWVzdGFtcCwgdGhpcyBwYWNrZXQgd2ls
bCBub3QgYmUgdGltZXN0YW1wZWRcbiIpOw0KPiA+ICsJfSBlbHNlIHsNCj4gPiArCQlza2Jfc2hp
bmZvKHNrYiktPnR4X2ZsYWdzIHw9IFNLQlRYX0lOX1BST0dSRVNTOw0KPiA+ICsJCS8qIHNjaGVk
dWxlIGNoZWNrIGZvciBUeCB0aW1lc3RhbXAgKi8NCj4gPiArCQlwdHAtPnR4X3NrYiA9IHNrYl9n
ZXQoc2tiKTsNCj4gPiArCQlzY2hlZHVsZV93b3JrKCZwdHAtPndvcmspOw0KPiA+ICsJfQ0KPiA+
ICt9DQo+IA0KPiANCj4gVGhpcyBpcyBhIG11bHRpIHF1ZXVlIGRldmljZS4NCj4gDQo+IFRoZXJl
Zm9yZSBtdWx0aXBsZSBjcHVzIGNvdWxkIGNhbGwgdGhpcyBmdW5jdGlvbiBhdCB0aGUgc2FtZSB0
aW1lLg0KPiANCj4gcHRwLT50eF9za2IgbmVlZHMgc29tZSBraW5kIG9mIFNNUCBwcm90ZWN0aW9u
Lg0KDQpJSXMgaXQgYSByZWFsIGlzc3VlIG9yIG9kZCBjb3JuZXItY2FzZSBpbiBhY3R1YWwgc2Nl
bmFyaW8/DQpSZWdhcmRsZXNzLCBJIGFzc3VtZSBpdCdzIGEgdGhlb3JldGljYWwgYnJlYWNoIHdh
aXRpbmcgZm9yIGFuDQphZHZlcnNhcnkgdG8gZXhwbG9pdCwgc28gYmV0dGVyIGZpeCBpdCBub3cu
DQoNCkknbGwgc2VuZCBhIGZpeCBsYXRlciB0b2RheS4gVGhhbmtzLg0K
