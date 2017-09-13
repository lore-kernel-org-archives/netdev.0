From: Josef Bacik <jbacik@fb.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Wed, 13 Sep 2017 19:44:17 +0000
Message-ID: <E068C58A-DC80-4D98-ADE6-8F05304EC7ED@fb.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
 <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
 <370b38d5-346c-91df-4ad4-79886ae3a9ba@redhat.com>
 <a4807126-1f17-20bd-dace-d9c6b6c4787b@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_E068C58ADC804D98ADE68F05304EC7EDfbcom_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Cole Robinson <crobinso@redhat.com>,
        Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a4807126-1f17-20bd-dace-d9c6b6c4787b@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_002_E068C58ADC804D98ADE68F05304EC7EDfbcom_
Content-Type: text/plain; charset="utf-8"
Content-ID: <F6E127AEFF56F04F9A33FBC5BCC83601@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64

QWxyaWdodCB0aGFua3MsIHRoaXMgc2hvdWxkIGZpeCBpdC4NCg0KSm9zZWYNCg0KT24gOS8xMy8x
NywgMTI6MTQgUE0sICJDb2xlIFJvYmluc29uIiA8Y3JvYmluc29AcmVkaGF0LmNvbT4gd3JvdGU6
DQoNCk9uIDA5LzEzLzIwMTcgMDE6NDAgUE0sIENvbGUgUm9iaW5zb24gd3JvdGU6DQo+IE9uIDA5
LzEzLzIwMTcgMDE6MjggUE0sIEpvc2VmIEJhY2lrIHdyb3RlOg0KPj4gU29ycnkgSSB0aG91Z2h0
IEkgaGFkIG1hZGUgdGhpcyBvdGhlciBmaXgsIGNhbiB5b3UgYXBwbHkgdGhpcyBvbiB0b3Agb2Yg
dGhlIG90aGVyIG9uZSBhbmQgdHJ5IHRoYXQ/ICBJIGhhdmUgbW9yZSB0aGluZ3MgdG8gdHJ5IGlm
IHRoaXMgZG9lc27igJl0IHdvcmssIHNvcnJ5IHlvdSBhcmUgcGxheWluZyBnbyBiZXR3ZWVuLCBi
dXQgSSB3YW50IHRvIG1ha2Ugc3VyZSBJIGtub3cgX3doaWNoXyBmaXggYWN0dWFsbHkgZml4ZXMg
dGhlIHByb2JsZW0sIGFuZCB0aGVuIGNsZWFuIHVwIGluIGZvbGxvd3VwIHBhdGNoZXMuICBUaGFu
a3MsDQo+Pg0KPiANCj4gSSdtIHRoZSBidWcgcmVwb3J0ZXIuIEknbGwgY29tYmluZSB0aGUgdHdv
IHBhdGNoZXMgYW5kIHJlcG9ydCBiYWNrDQo+IA0KDQpOb3BlLCBpc3N1ZSBpcyBzdGlsbCBwcmVz
ZW50IHdpdGggYm90aCBwYXRjaGVzIGFwcGxpZWQuIFRyaWVkIG15IG93biBidWlsZCBhbmQNCmEg
cGFja2FnZSBMYXVyYSBwcm92aWRlZA0KDQpUaGFua3MsDQpDb2xlDQoNCg0KDQo=

--_002_E068C58ADC804D98ADE68F05304EC7EDfbcom_
Content-Type: application/octet-stream;
	name="0001-net-don-t-fast-patch-mismatched-sockets-in-STRICT-mo.patch"
Content-Description: 0001-net-don-t-fast-patch-mismatched-sockets-in-STRICT-mo.patch
Content-Disposition: attachment;
	filename="0001-net-don-t-fast-patch-mismatched-sockets-in-STRICT-mo.patch";
	size=1182; creation-date="Wed, 13 Sep 2017 19:44:17 GMT";
	modification-date="Wed, 13 Sep 2017 19:44:17 GMT"
Content-ID: <0C6E95F779F32949B9FB11F521E1200D@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64

RnJvbSA4ZDNkYTZkMzBhN2M2MzAzNGQ0ZmY3ZDRmYzMzZWE5ZTNmMjNjZjQxIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb3NlZiBCYWNpayA8am9zZWZAdG94aWNwYW5kYS5jb20+CkRh
dGU6IFdlZCwgMTMgU2VwIDIwMTcgMTI6NDI6MTMgLTA3MDAKU3ViamVjdDogW1BBVENIXSBuZXQ6
IGRvbid0IGZhc3QgcGF0Y2ggbWlzbWF0Y2hlZCBzb2NrZXRzIGluIFNUUklDVCBtb2RlCgpXaXRo
IEZBU1RSRVVTRV9TVFJJQ1Qgd2UgbWF5IGhhdmUgc29ja2V0cyBvbiB0aGUgdGIgdGhhdCBkb24n
dCBtYXRjaCBvdXIKZmFzdF9zayBpbmZvcm1hdGlvbiwgc28gaWYgb3VyIG5ldyBzb2NrZXQgZG9u
J3Qgc3RyaWN0bHkgbWF0Y2ggdGhlCmZhc3Rfc2sgaW5mbyB3ZSBuZWVkIHRvIG5vdCBnbyBkb3du
IHRoZSBmYXN0IHBhdGggYW5kIGRvIHRoZQppbmV0X2Nza19iaW5kX2NvbmZsaWN0IHNvIHdlIGNh
biBsb29rIGF0IHRoZSBvdGhlciBzb2NrZXRzIG9uIHRoZSB0Yi4KClNpZ25lZC1vZmYtYnk6IEpv
c2VmIEJhY2lrIDxqb3NlZkB0b3hpY3BhbmRhLmNvbT4KLS0tCiBuZXQvaXB2NC9pbmV0X2Nvbm5l
Y3Rpb25fc29jay5jIHwgMiArKwogMSBmaWxlIGNoYW5nZWQsIDIgaW5zZXJ0aW9ucygrKQoKZGlm
ZiAtLWdpdCBhL25ldC9pcHY0L2luZXRfY29ubmVjdGlvbl9zb2NrLmMgYi9uZXQvaXB2NC9pbmV0
X2Nvbm5lY3Rpb25fc29jay5jCmluZGV4IGZmOGIxNWE5OWU0Mi4uZmU5Y2Y0ODYyZGUyIDEwMDY0
NAotLS0gYS9uZXQvaXB2NC9pbmV0X2Nvbm5lY3Rpb25fc29jay5jCisrKyBiL25ldC9pcHY0L2lu
ZXRfY29ubmVjdGlvbl9zb2NrLmMKQEAgLTI2Myw2ICsyNjMsOCBAQCBzdGF0aWMgaW5saW5lIGlu
dCBza19yZXVzZXBvcnRfbWF0Y2goc3RydWN0IGluZXRfYmluZF9idWNrZXQgKnRiLAogCSAqLwog
CWlmICh0Yi0+ZmFzdHJldXNlcG9ydCA9PSBGQVNUUkVVU0VQT1JUX0FOWSkKIAkJcmV0dXJuIDE7
CisJaWYgKHRiLT5mYXN0X2lwdjZfb25seSAmJiB0Yi0+ZmFzdF9za19mYW1pbHkgIT0gc2stPnNr
X2ZhbWlseSkKKwkJcmV0dXJuIDA7CiAjaWYgSVNfRU5BQkxFRChDT05GSUdfSVBWNikKIAlpZiAo
dGItPmZhc3Rfc2tfZmFtaWx5ID09IEFGX0lORVQ2KQogCQlyZXR1cm4gaXB2Nl9yY3Zfc2FkZHJf
ZXF1YWwoJnRiLT5mYXN0X3Y2X3Jjdl9zYWRkciwKLS0gCjIuMTMuNQoK

--_002_E068C58ADC804D98ADE68F05304EC7EDfbcom_--
