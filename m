From: Amit Salecha <amit.salecha@qlogic.com>
Subject: RE: [PATCHv3 NEXT 7/7] qlcnic: turn off lro when rxcsum is disabled.
Date: Wed, 18 Aug 2010 01:39:45 -0500
Message-ID: <99737F4847ED0A48AECC9F4A1974A4B80F86E690DF@MNEXMB2.qlogic.org>
References: <1282041265-32591-1-git-send-email-amit.salecha@qlogic.com>
	 <1282041265-32591-8-git-send-email-amit.salecha@qlogic.com>
 <1282056532.24541.89.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexcashub1.qlogic.com ([198.70.193.61]:26913 "EHLO
	avexcashub1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab0HRGjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 02:39:48 -0400
In-Reply-To: <1282056532.24541.89.camel@Joe-Laptop>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pj4gSSB0aGluayBuZXRkZXZfPGxldmVsPiBzaG91bGQgYmUgdXNlZCB3aGVuIGEgc3RydWN0IG5l
dF9kZXZpY2UgKiBpcyBhdmFpbGFibGUuDQoNCldpbGwgdGFrZSBjYXJlIGluIGZ1dHVyZS4NCg0K
LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IEpvZSBQZXJjaGVzIFttYWlsdG86am9l
QHBlcmNoZXMuY29tXSANClNlbnQ6IFR1ZXNkYXksIEF1Z3VzdCAxNywgMjAxMCA4OjE5IFBNDQpU
bzogQW1pdCBTYWxlY2hhDQpDYzogZGF2ZW1AZGF2ZW1sb2Z0Lm5ldDsgbmV0ZGV2QHZnZXIua2Vy
bmVsLm9yZzsgQW1lZW4gUmFobWFuOyBTdWNoZXRhIENoYWtyYWJvcnR5DQpTdWJqZWN0OiBSZTog
W1BBVENIdjMgTkVYVCA3LzddIHFsY25pYzogdHVybiBvZmYgbHJvIHdoZW4gcnhjc3VtIGlzIGRp
c2FibGVkLg0KDQpPbiBUdWUsIDIwMTAtMDgtMTcgYXQgMDM6MzQgLTA3MDAsIEFtaXQgS3VtYXIg
U2FsZWNoYSB3cm90ZToNCj4gRnJvbTogU3VjaGV0YSBDaGFrcmFib3J0eSA8c3VjaGV0YS5jaGFr
cmFib3J0eUBxbG9naWMuY29tPg0KDQpUaGFua3MgYWxsLCAyIG1pbm9yIGNvbW1lbnRzIGJlbG93
Lg0KDQo+IC0tLSBhL2RyaXZlcnMvbmV0L3FsY25pYy9xbGNuaWNfZXRodG9vbC5jDQo+ICsrKyBi
L2RyaXZlcnMvbmV0L3FsY25pYy9xbGNuaWNfZXRodG9vbC5jDQo+IEBAIC04MTgsNyArODE4LDIx
IEBAIHN0YXRpYyB1MzIgcWxjbmljX2dldF9yeF9jc3VtKHN0cnVjdCBuZXRfZGV2aWNlICpkZXYp
DQo+ICBzdGF0aWMgaW50IHFsY25pY19zZXRfcnhfY3N1bShzdHJ1Y3QgbmV0X2RldmljZSAqZGV2
LCB1MzIgZGF0YSkNCltdDQo+IAlkZXZfaW5mbygmYWRhcHRlci0+cGRldi0+ZGV2LCAiZGlzYWJs
aW5nIExSTyBhcyByeF9jc3VtIGlzIG9mZlxuIik7DQoNCkkgdGhpbmsgbmV0ZGV2XzxsZXZlbD4g
c2hvdWxkIGJlIHVzZWQgd2hlbiBhDQpzdHJ1Y3QgbmV0X2RldmljZSAqIGlzIGF2YWlsYWJsZS4N
Cg0KCW5ldGRldl9pbmZvKGRldiwgImRpc2FibGluZyBMUk8gYXMgcnhfY3N1bSBpcyBvZmZcbiIp
Ow0KDQo+IEBAIC0xMDAxLDYgKzEwMTUsMTUgQEAgc3RhdGljIGludCBxbGNuaWNfc2V0X2ZsYWdz
KHN0cnVjdCBuZXRfZGV2aWNlICpuZXRkZXYsIHUzMiBkYXRhKQ0KW10NCj4gKwlpZiAoIWFkYXB0
ZXItPnJ4X2NzdW0pIHsNCj4gKwkJZGV2X2luZm8oJmFkYXB0ZXItPnBkZXYtPmRldiwgInJ4IGNz
dW0gaXMgb2ZmLCAiDQo+ICsJCQkiY2Fubm90IHRvZ2dsZSBscm9cbiIpOw0KDQoJCW5ldGRldl9p
bmZvKG5ldGRldiwgInJ4IGNzdW0gaXMgb2ZmLCBjYW5ub3QgdG9nZ2xlIExST1xuIik7DQoNCmFu
ZCBwbGVhc2UgdXNlIGNvbnNpc3RlbnQgYWNyb255bSBjYXNlLg0KDQoNCg==
