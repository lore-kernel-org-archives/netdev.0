From: Josef Bacik <jbacik@fb.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Fri, 15 Sep 2017 17:51:59 +0000
Message-ID: <BD049B00-DD0A-449F-A017-9E73178685DE@fb.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
 <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
 <370b38d5-346c-91df-4ad4-79886ae3a9ba@redhat.com>
 <a4807126-1f17-20bd-dace-d9c6b6c4787b@redhat.com>
 <E068C58A-DC80-4D98-ADE6-8F05304EC7ED@fb.com>
 <813386f2-81ba-db8c-e86d-f36cd1b89537@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_BD049B00DD0A449FA0179E73178685DEfbcom_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cole Robinson <crobinso@redhat.com>,
        Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <813386f2-81ba-db8c-e86d-f36cd1b89537@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_002_BD049B00DD0A449FA0179E73178685DEfbcom_
Content-Type: text/plain; charset="utf-8"
Content-ID: <8E152A6C7EB5C048B0041D035FFBF2C6@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64

RmluYWxseSBnb3QgYWNjZXNzIHRvIGEgYm94IHRvIHJ1biB0aGlzIGRvd24gbXlzZWxmLiAgVGhp
cyBwYXRjaCBvbiB0b3Agb2YgdGhlIG90aGVyIHBhdGNoZXMgZml4ZXMgdGhlIHByb2JsZW0gZm9y
IG1lLCBjb3VsZCB5b3UgdmVyaWZ5IGl0IHdvcmtzIGZvciB5b3U/ICBUaGFua3MsDQoNCkpvc2Vm
DQoNCk9uIDkvMTMvMTcsIDM6NDkgUE0sICJDb2xlIFJvYmluc29uIiA8Y3JvYmluc29AcmVkaGF0
LmNvbT4gd3JvdGU6DQoNCk9uIDA5LzEzLzIwMTcgMDM6NDQgUE0sIEpvc2VmIEJhY2lrIHdyb3Rl
Og0KPiBBbHJpZ2h0IHRoYW5rcywgdGhpcyBzaG91bGQgZml4IGl0Lg0KPiANCg0KU3RpbGwgbm8g
bHVjayB3aXRoIGFsbCB0aHJlZSBwYXRjaGVzIGFwcGxpZWQgdG8gZmVkb3JhIDQuMTIuOC0zMDAg
UlBNLiBQcmV0dHkNCnN1cmUgSSBkaWRuJ3QgbWVzcyB1cCB0aGUgdGVzdGluZyBidXQgc2luY2Ug
SSByYXJlbHkgZG8ga2VybmVsIGJ1aWxkcyBpdCdzIG5vdA0KaW1wb3NzaWJsZS4uLg0KDQpUaGFu
a3MsDQpDb2xlDQoNCg0KDQo=

--_002_BD049B00DD0A449FA0179E73178685DEfbcom_
Content-Type: application/octet-stream;
	name="0001-net-call-sk_reuseport_match-if-we-are-a-reusesock.patch"
Content-Description: 0001-net-call-sk_reuseport_match-if-we-are-a-reusesock.patch
Content-Disposition: attachment;
	filename="0001-net-call-sk_reuseport_match-if-we-are-a-reusesock.patch";
	size=1223; creation-date="Fri, 15 Sep 2017 17:51:59 GMT";
	modification-date="Fri, 15 Sep 2017 17:51:59 GMT"
Content-ID: <4C85F42444273648BB106C36633A9494@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64

RnJvbSBiNzBlN2E3OGFmMmM0YzA5MGNhODE2ZDlmMTI3YTJmMWU1ODY2ZmI4IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb3NlZiBCYWNpayA8am9zZWZAdG94aWNwYW5kYS5jb20+CkRh
dGU6IEZyaSwgMTUgU2VwIDIwMTcgMTA6NDg6MTcgLTA3MDAKU3ViamVjdDogW1BBVENIXSBuZXQ6
IGNhbGwgc2tfcmV1c2Vwb3J0X21hdGNoIGlmIHdlIGFyZSBhIHJldXNlc29jawoKV2hlbiBhZGRp
bmcgdGhlIHNrX3JldXNlcG9ydF9tYXRjaCBoZWxwZXIgSSBzY3Jld2VkIHVwIGFuZCBtYWRlIGl0
IHNvIHdlCnVuY29uZGl0aW9uYWxseSBzdWNjZWVkZWQgaWYgb3VyIHNvY2tldCB3YXMgYSByZXVz
ZXBvcnQgc29ja2V0IGFuZCB0aGUKdGIgd2FzIG1hcmtlZCByZXVzZWFibGUuICBGaXggdGhpcyBi
eSBhY3R1YWxseSBjYWxsaW5nCnNrX3JldXNlcG9ydF9tYXRjaCgpIHRvIG1ha2Ugc3VyZSBvdXIg
bmV3IHNvY2tldCBtYXRjaGVzIHRoZSB0YgpyZXVzZXBvcnQgc2V0dGluZ3MuCgpTaWduZWQtb2Zm
LWJ5OiBKb3NlZiBCYWNpayA8am9zZWZAdG94aWNwYW5kYS5jb20+Ci0tLQogbmV0L2lwdjQvaW5l
dF9jb25uZWN0aW9uX3NvY2suYyB8IDMgKy0tCiAxIGZpbGUgY2hhbmdlZCwgMSBpbnNlcnRpb24o
KyksIDIgZGVsZXRpb25zKC0pCgpkaWZmIC0tZ2l0IGEvbmV0L2lwdjQvaW5ldF9jb25uZWN0aW9u
X3NvY2suYyBiL25ldC9pcHY0L2luZXRfY29ubmVjdGlvbl9zb2NrLmMKaW5kZXggZmU5Y2Y0ODYy
ZGUyLi4wZTMwZTUwNGM3ZDQgMTAwNjQ0Ci0tLSBhL25ldC9pcHY0L2luZXRfY29ubmVjdGlvbl9z
b2NrLmMKKysrIGIvbmV0L2lwdjQvaW5ldF9jb25uZWN0aW9uX3NvY2suYwpAQCAtMzE2LDggKzMx
Niw3IEBAIGludCBpbmV0X2Nza19nZXRfcG9ydChzdHJ1Y3Qgc29jayAqc2ssIHVuc2lnbmVkIHNo
b3J0IHNudW0pCiAJCWlmIChzay0+c2tfcmV1c2UgPT0gU0tfRk9SQ0VfUkVVU0UpCiAJCQlnb3Rv
IHN1Y2Nlc3M7CiAKLQkJaWYgKCh0Yi0+ZmFzdHJldXNlID4gMCAmJiByZXVzZSkgfHwKLQkJICAg
IHNrX3JldXNlcG9ydF9tYXRjaCh0Yiwgc2spKQorCQlpZiAodGItPmZhc3RyZXVzZSA+IDAgJiYg
cmV1c2UgJiYgc2tfcmV1c2Vwb3J0X21hdGNoKHRiLCBzaykpCiAJCQlnb3RvIHN1Y2Nlc3M7CiAJ
CWlmIChpbmV0X2Nza19iaW5kX2NvbmZsaWN0KHNrLCB0YiwgdHJ1ZSwgdHJ1ZSkpCiAJCQlnb3Rv
IGZhaWxfdW5sb2NrOwotLSAKMi4xMy41Cgo=

--_002_BD049B00DD0A449FA0179E73178685DEfbcom_--
