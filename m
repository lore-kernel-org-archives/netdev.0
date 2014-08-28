From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/2] tipc: refactor name table updates out
 of named packet receive routine
Date: Wed, 27 Aug 2014 18:10:25 -0700 (PDT)
Message-ID: <20140827.181025.607135623492602985.davem@davemloft.net>
References: <1409065550-9648-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-7
Content-Transfer-Encoding: base64
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
	richard.alpe@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42607 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965054AbaH1BK0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 21:10:26 -0400
In-Reply-To: <1409065550-9648-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogPGVyaWsuaHVnbmVAZXJpY3Nzb24uY29tPg0KRGF0ZTogVHVlLCAyNiBBdWcgMjAxNCAx
NzowNTo0OSArMDIwMA0KDQo+IEZyb206IEVyaWsgSHVnbmUgPGVyaWsuaHVnbmVAZXJpY3Nzb24u
Y29tPg0KPiANCj4gV2UgbmVlZCB0byBwZXJmb3JtIHRoZSBzYW1lIGFjdGlvbnMgd2hlbiBwcm9j
ZXNzaW5nIGRlZmVycmVkIG5hbWUNCj4gdGFibGUgdXBkYXRlcywgc28gdGhpcyBmdW5jdGlvbmFs
aXR5IGlzIG1vdmVkIHRvIGEgc2VwYXJhdGUNCj4gZnVuY3Rpb24uDQo+IA0KPiBTaWduZWQtb2Zm
LWJ5OiBFcmlrIEh1Z25lIDxlcmlrLmh1Z25lQGVyaWNzc29uLmNvbT4NCj4gU2lnbmVkLW9mZi1i
eTogSm9uIE1hbG95IDxqb24ubWFsb3lAZXJpY3Nzb24uY29tPg0KPiBBY2tlZC1ieTogWWluZyBY
dWUgPHlpbmcueHVlQHdpbmRyaXZlci5jb20+DQoNClRoaXMgcGF0Y2ggc2V0IGFkZHMgY29tcGls
ZXIgd2FybmluZ3M6DQoNCm5ldC90aXBjL25hbWVfZGlzdHIuYzogSW4gZnVuY3Rpb24goXRpcGNf
bmFtZWRfcHJvY2Vzc19iYWNrbG9nojoNCm5ldC90aXBjL25hbWVfZGlzdHIuYzozNDY6Nzogd2Fy
bmluZzogY29tcGFyaXNvbiBvZiBkaXN0aW5jdCBwb2ludGVyIHR5cGVzIGxhY2tzIGEgY2FzdCBb
ZW5hYmxlZCBieSBkZWZhdWx0XQ0KbmV0L3RpcGMvbmFtZV9kaXN0ci5jOjM0Njo3OiB3YXJuaW5n
OiBjb21wYXJpc29uIG9mIGRpc3RpbmN0IHBvaW50ZXIgdHlwZXMgbGFja3MgYSBjYXN0IFtlbmFi
bGVkIGJ5IGRlZmF1bHRdDQoNClBsZWFzZSBmaXggdGhlbSBhbmQgcmVzdWJtaXQgdGhlIGVudGly
ZSBzZXJpZXMuDQoNCg0KVGhhbmtzLg0K
