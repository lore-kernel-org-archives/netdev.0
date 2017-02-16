From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v7 2/2] qede: Add driver support for PTP
Date: Thu, 16 Feb 2017 12:45:43 +0000
Message-ID: <BL2PR07MB2306B4233E972F10012DF7398D5A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1487147051-14350-1-git-send-email-Yuval.Mintz@cavium.com>
         <1487147051-14350-3-git-send-email-Yuval.Mintz@cavium.com>
 <1487247814.1311.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <BL2PR07MB2306CD2B1CFECEE4AAB425108D5A0@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        "richardcochran@gmail.com" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0084.outbound.protection.outlook.com ([104.47.41.84]:47552
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754512AbdBPMpx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:45:53 -0500
In-Reply-To: <BL2PR07MB2306CD2B1CFECEE4AAB425108D5A0@BL2PR07MB2306.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQo+ID4gPiArdm9pZCBxZWRlX3B0cF90eF90cyhzdHJ1Y3QgcWVkZV9kZXYgKmVkZXYsIHN0cnVj
dCBza19idWZmICpza2IpIHsNCj4gPiA+ICsJc3RydWN0IHFlZGVfcHRwICpwdHA7DQo+ID4gPiAr
DQo+ID4gPiArCXB0cCA9IGVkZXYtPnB0cDsNCj4gPiA+ICsJaWYgKCFwdHApDQo+ID4gPiArCQly
ZXR1cm47DQo+ID4gPiArDQo+ID4gPiArCWlmICh1bmxpa2VseSghKGVkZXYtPmZsYWdzICYgUUVE
RV9UWF9USU1FU1RBTVBJTkdfRU4pKSkgew0KPiA+ID4gKwkJRFBfTk9USUNFKGVkZXYsDQo+ID4g
PiArCQkJICAiVHggdGltZXN0YW1waW5nIHdhcyBub3QgZW5hYmxlZCwgdGhpcyBwYWNrZXQgd2ls
bA0KPiA+IG5vdCBiZSB0aW1lc3RhbXBlZFxuIik7DQo+ID4gPiArCX0gZWxzZSBpZiAodW5saWtl
bHkocHRwLT50eF9za2IpKSB7DQo+ID4gPiArCQlEUF9OT1RJQ0UoZWRldiwNCj4gPiA+ICsJCQkg
ICJUaGUgZGV2aWNlIHN1cHBvcnRzIG9ubHkgYSBzaW5nbGUgb3V0c3RhbmRpbmcNCj4gPiBwYWNr
ZXQgdG8gdGltZXN0YW1wLCB0aGlzIHBhY2tldCB3aWxsIG5vdCBiZSB0aW1lc3RhbXBlZFxuIik7
DQo+ID4gPiArCX0gZWxzZSB7DQo+ID4gPiArCQlza2Jfc2hpbmZvKHNrYiktPnR4X2ZsYWdzIHw9
IFNLQlRYX0lOX1BST0dSRVNTOw0KPiA+ID4gKwkJLyogc2NoZWR1bGUgY2hlY2sgZm9yIFR4IHRp
bWVzdGFtcCAqLw0KPiA+ID4gKwkJcHRwLT50eF9za2IgPSBza2JfZ2V0KHNrYik7DQo+ID4gPiAr
CQlzY2hlZHVsZV93b3JrKCZwdHAtPndvcmspOw0KPiA+ID4gKwl9DQo+ID4gPiArfQ0KPiA+DQo+
ID4NCj4gPiBUaGlzIGlzIGEgbXVsdGkgcXVldWUgZGV2aWNlLg0KPiA+DQo+ID4gVGhlcmVmb3Jl
IG11bHRpcGxlIGNwdXMgY291bGQgY2FsbCB0aGlzIGZ1bmN0aW9uIGF0IHRoZSBzYW1lIHRpbWUu
DQo+ID4NCj4gPiBwdHAtPnR4X3NrYiBuZWVkcyBzb21lIGtpbmQgb2YgU01QIHByb3RlY3Rpb24u
DQo+IA0KPiBJSXMgaXQgYSByZWFsIGlzc3VlIG9yIG9kZCBjb3JuZXItY2FzZSBpbiBhY3R1YWwg
c2NlbmFyaW8/DQoNCndlIGhhdmUgYSBwcmludCBnb2luZyB0byBvdXQgYXQgZGVmYXVsdCB3aGVu
IGVuY291bnRlcmluZw0KdGhpczsgU28gYXNzdW1pbmcgaXQncyBhIHJlYWwgbGlmZSBzY2VuYXJp
bywgd2Ugc2hvdWxkIHByb2JhYmx5DQpyZW1vdmUgaXQgYXMgd2VsbC4NCklmIGl0J3Mgbm90LCBJ
IGNhbiBzaW1wbHkgY29udmVydCBpdCB0byBXQVJOX09OQ0UoKS4NCg0K
