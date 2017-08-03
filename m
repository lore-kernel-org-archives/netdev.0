From: "Patil, Harish" <Harish.Patil@cavium.com>
Subject: Re: [PATCH 2/2] qlcnic: add const to bin_attribute structure
Date: Thu, 3 Aug 2017 03:24:37 +0000
Message-ID: <D5A894F4.157FD1%Harish.Patil@cavium.com>
References: <1501696634-15765-1-git-send-email-bhumirks@gmail.com>
 <1501696634-15765-3-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: Bhumika Goyal <bhumirks@gmail.com>,
        "julia.lawall@lip6.fr" <julia.lawall@lip6.fr>,
        "kvalo@codeaurora.org" <kvalo@codeaurora.org>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>,
        Dept-GE Linux NIC Dev <Dept-GELinuxNICDev@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0069.outbound.protection.outlook.com ([104.47.38.69]:2592
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751073AbdHCDYk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Aug 2017 23:24:40 -0400
In-Reply-To: <1501696634-15765-3-git-send-email-bhumirks@gmail.com>
Content-Language: en-US
Content-ID: <8CF4BEA7EE9C5447BDE1C3F1CE507595@namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LS0tLS1PcmlnaW5hbCBNZXNzYWdlLS0tLS0NCkZyb206IEJodW1pa2EgR295YWwgPGJodW1pcmtz
QGdtYWlsLmNvbT4NCkRhdGU6IFdlZG5lc2RheSwgQXVndXN0IDIsIDIwMTcgYXQgMTE6MjcgUE0N
ClRvOiAianVsaWEubGF3YWxsQGxpcDYuZnIiIDxqdWxpYS5sYXdhbGxAbGlwNi5mcj4sICJrdmFs
b0Bjb2RlYXVyb3JhLm9yZyINCjxrdmFsb0Bjb2RlYXVyb3JhLm9yZz4sICJsaW51eC13aXJlbGVz
c0B2Z2VyLmtlcm5lbC5vcmciDQo8bGludXgtd2lyZWxlc3NAdmdlci5rZXJuZWwub3JnPiwgIm5l
dGRldkB2Z2VyLmtlcm5lbC5vcmciDQo8bmV0ZGV2QHZnZXIua2VybmVsLm9yZz4sICJsaW51eC1r
ZXJuZWxAdmdlci5rZXJuZWwub3JnIg0KPGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmc+LCBI
YXJpc2ggUGF0aWwgPEhhcmlzaC5QYXRpbEBjYXZpdW0uY29tPiwNCiJDaG9wcmEsIE1hbmlzaCIg
PE1hbmlzaC5DaG9wcmFAY2F2aXVtLmNvbT4sIERlcHQtR0UgTGludXggTklDIERldg0KPERlcHQt
R0VMaW51eE5JQ0RldkBjYXZpdW0uY29tPg0KQ2M6IEJodW1pa2EgR295YWwgPGJodW1pcmtzQGdt
YWlsLmNvbT4NClN1YmplY3Q6IFtQQVRDSCAyLzJdIHFsY25pYzogYWRkIGNvbnN0IHRvIGJpbl9h
dHRyaWJ1dGUgc3RydWN0dXJlDQoNCj5BZGQgY29uc3QgdG8gYmluX2F0dHJpYnV0ZSBzdHJ1Y3R1
cmUgYXMgaXQgaXMgb25seSBwYXNzZWQgdG8gdGhlDQo+ZnVuY3Rpb25zIHN5c2ZzX3tyZW1vdmUv
Y3JlYXRlfV9iaW5fZmlsZS4gVGhlIGNvcnJlc3BvbmRpbmcNCj5hcmd1bWVudHMgYXJlIG9mIHR5
cGUgY29uc3QsIHNvIGRlY2xhcmUgdGhlIHN0cnVjdHVyZSB0byBiZSBjb25zdC4NCj4NCj5TaWdu
ZWQtb2ZmLWJ5OiBCaHVtaWthIEdveWFsIDxiaHVtaXJrc0BnbWFpbC5jb20+DQo+LS0tDQo+IGRy
aXZlcnMvbmV0L2V0aGVybmV0L3Fsb2dpYy9xbGNuaWMvcWxjbmljX3N5c2ZzLmMgfCAyICstDQo+
IDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQ0KPg0KPmRpZmYg
LS1naXQgYS9kcml2ZXJzL25ldC9ldGhlcm5ldC9xbG9naWMvcWxjbmljL3FsY25pY19zeXNmcy5j
DQo+Yi9kcml2ZXJzL25ldC9ldGhlcm5ldC9xbG9naWMvcWxjbmljL3FsY25pY19zeXNmcy5jDQo+
aW5kZXggNzMwMjdhNi4uODJmY2I4MyAxMDA2NDQNCj4tLS0gYS9kcml2ZXJzL25ldC9ldGhlcm5l
dC9xbG9naWMvcWxjbmljL3FsY25pY19zeXNmcy5jDQo+KysrIGIvZHJpdmVycy9uZXQvZXRoZXJu
ZXQvcWxvZ2ljL3FsY25pYy9xbGNuaWNfc3lzZnMuYw0KPkBAIC0xMjQ4LDcgKzEyNDgsNyBAQCBz
dGF0aWMgc3NpemVfdA0KPnFsY25pY184M3h4X3N5c2ZzX2ZsYXNoX3dyaXRlX2hhbmRsZXIoc3Ry
dWN0IGZpbGUgKmZpbHAsDQo+IAkud3JpdGUgPSBxbGNuaWNfc3lzZnNfd3JpdGVfcG1fY29uZmln
LA0KPiB9Ow0KPiANCj4tc3RhdGljIHN0cnVjdCBiaW5fYXR0cmlidXRlIGJpbl9hdHRyX2ZsYXNo
ID0gew0KPitzdGF0aWMgY29uc3Qgc3RydWN0IGJpbl9hdHRyaWJ1dGUgYmluX2F0dHJfZmxhc2gg
PSB7DQo+IAkuYXR0ciA9IHsubmFtZSA9ICJmbGFzaCIsIC5tb2RlID0gKFNfSVJVR08gfCBTX0lX
VVNSKX0sDQo+IAkuc2l6ZSA9IDAsDQo+IAkucmVhZCA9IHFsY25pY184M3h4X3N5c2ZzX2ZsYXNo
X3JlYWRfaGFuZGxlciwNCj4tLSANCj4xLjkuMQ0KPg0KPkFja2VkLWJ5OiBIYXJpc2ggUGF0aWwg
PGhhcmlzaC5wYXRpbEBjYXZpdW0uY29tPg0KDQo=
