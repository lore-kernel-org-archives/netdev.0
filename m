From: Josef Bacik <jbacik@fb.com>
Subject: Re: 319554f284dd ("inet: don't use sk_v6_rcv_saddr directly") causes
 bind port regression
Date: Wed, 13 Sep 2017 17:28:25 +0000
Message-ID: <EF55EF02-AD40-4F06-8C07-4F9F4221BFE6@fb.com>
References: <1a8ef376-387e-e0fc-7362-e1fd2c2c45d3@redhat.com>
 <AF16C126-99CA-401A-B803-AA05CDFBFF93@fb.com>
 <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
        boundary="_002_EF55EF02AD404F068C074F9F4221BFE6fbcom_"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Cole Robinson <crobinso@redhat.com>
To: Laura Abbott <labbott@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        "Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <588f3795-931e-7779-4ec7-5fe7d4437927@redhat.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--_002_EF55EF02AD404F068C074F9F4221BFE6fbcom_
Content-Type: text/plain; charset="utf-8"
Content-ID: <9B3EF808575C9A4AA7EF19EF7D355366@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64

U29ycnkgSSB0aG91Z2h0IEkgaGFkIG1hZGUgdGhpcyBvdGhlciBmaXgsIGNhbiB5b3UgYXBwbHkg
dGhpcyBvbiB0b3Agb2YgdGhlIG90aGVyIG9uZSBhbmQgdHJ5IHRoYXQ/ICBJIGhhdmUgbW9yZSB0
aGluZ3MgdG8gdHJ5IGlmIHRoaXMgZG9lc27igJl0IHdvcmssIHNvcnJ5IHlvdSBhcmUgcGxheWlu
ZyBnbyBiZXR3ZWVuLCBidXQgSSB3YW50IHRvIG1ha2Ugc3VyZSBJIGtub3cgX3doaWNoXyBmaXgg
YWN0dWFsbHkgZml4ZXMgdGhlIHByb2JsZW0sIGFuZCB0aGVuIGNsZWFuIHVwIGluIGZvbGxvd3Vw
IHBhdGNoZXMuICBUaGFua3MsDQoNCkpvc2VmDQoNCk9uIDkvMTMvMTcsIDg6NDUgQU0sICJMYXVy
YSBBYmJvdHQiIDxsYWJib3R0QHJlZGhhdC5jb20+IHdyb3RlOg0KDQpPbiAwOS8xMi8yMDE3IDA0
OjEyIFBNLCBKb3NlZiBCYWNpayB3cm90ZToNCj4gRmlyc3QgSeKAmW0gc3VwZXIgc29ycnkgZm9y
IHRoZSB0b3AgcG9zdCwgSeKAmW0gYXQgcGx1bWJlcnMgYW5kIEkgZm9yZ290IHRvIHVwbG9hZCBt
eSBtdXR0cmMgdG8gbXkgbmV3IGNsb3VkIGluc3RhbmNlLCBzbyBJ4oCZbSBzY3Jld2VkIHVzaW5n
IG91dGxvb2suDQo+IA0KPiBJIGhhdmUgYSBjb21wbGV0ZWx5IHVudGVzdGVkLCB1bmNvbXBpbGVk
IHBhdGNoIHRoYXQgSSB0aGluayB3aWxsIGZpeCB0aGUgcHJvYmxlbSwgd291bGQgeW91IG1pbmQg
Z2l2aW5nIGl0IGEgZ28/ICBUaGFua3MsDQo+IA0KPiBKb3NlZg0KDQpUaGFua3MgZm9yIHRoZSBx
dWljayB0dXJuYXJvdW5kLiBVbmZvcnR1bmF0ZWx5LCB0aGUgcHJvYmxlbSBpcyBzdGlsbA0KcmVw
cm9kdWNpYmxlIGFjY29yZGluZyB0byB0aGUgcmVwb3J0ZXIuDQoNClRoYW5rcywNCkxhdXJhDQoN
Cg0K

--_002_EF55EF02AD404F068C074F9F4221BFE6fbcom_
Content-Type: application/octet-stream;
	name="0001-net-use-inet6_rcv_saddr-to-compare-sockets.patch"
Content-Description: 0001-net-use-inet6_rcv_saddr-to-compare-sockets.patch
Content-Disposition: attachment;
	filename="0001-net-use-inet6_rcv_saddr-to-compare-sockets.patch"; size=1085;
	creation-date="Wed, 13 Sep 2017 17:28:25 GMT";
	modification-date="Wed, 13 Sep 2017 17:28:25 GMT"
Content-ID: <BE9F535FC32834439F7D8EA9C687071F@namprd15.prod.outlook.com>
Content-Transfer-Encoding: base64

RnJvbSAzODA5NjhmNThkNTQzYWM5ZWMwY2IxYWExMWRiMzk3OWYzYWVlNjlkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBKb3NlZiBCYWNpayA8am9zZWZAdG94aWNwYW5kYS5jb20+CkRh
dGU6IFdlZCwgMTMgU2VwIDIwMTcgMTA6MjQ6MjIgLTA3MDAKU3ViamVjdDogW1BBVENIXSBuZXQ6
IHVzZSBpbmV0Nl9yY3Zfc2FkZHIgdG8gY29tcGFyZSBzb2NrZXRzCgpJbiBpcHY2X3Jjdl9zYWRk
cl9lcXVhbCgpIHdlIG5lZWQgdG8gdXNlIGluZXQ2X3Jjdl9zYWRkcihzaykgZm9yIHRoZQppcHY2
IGNvbXBhcmUgd2l0aCB0aGUgZmFzdCBzb2NrZXQgaW5mb3JtYXRpb24gdG8gbWFrZSBzdXJlIHdl
J3JlIGRvaW5nCnRoZSBwcm9wZXIgY29tcGFyaXNvbnMuCgpTaWduZWQtb2ZmLWJ5OiBKb3NlZiBC
YWNpayA8am9zZWZAdG94aWNwYW5kYS5jb20+Ci0tLQogbmV0L2lwdjQvaW5ldF9jb25uZWN0aW9u
X3NvY2suYyB8IDIgKy0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlv
bigtKQoKZGlmZiAtLWdpdCBhL25ldC9pcHY0L2luZXRfY29ubmVjdGlvbl9zb2NrLmMgYi9uZXQv
aXB2NC9pbmV0X2Nvbm5lY3Rpb25fc29jay5jCmluZGV4IDNjZmY5NWYxMDk5NS4uZmY4YjE1YTk5
ZTQyIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9pbmV0X2Nvbm5lY3Rpb25fc29jay5jCisrKyBiL25l
dC9pcHY0L2luZXRfY29ubmVjdGlvbl9zb2NrLmMKQEAgLTI2Niw3ICsyNjYsNyBAQCBzdGF0aWMg
aW5saW5lIGludCBza19yZXVzZXBvcnRfbWF0Y2goc3RydWN0IGluZXRfYmluZF9idWNrZXQgKnRi
LAogI2lmIElTX0VOQUJMRUQoQ09ORklHX0lQVjYpCiAJaWYgKHRiLT5mYXN0X3NrX2ZhbWlseSA9
PSBBRl9JTkVUNikKIAkJcmV0dXJuIGlwdjZfcmN2X3NhZGRyX2VxdWFsKCZ0Yi0+ZmFzdF92Nl9y
Y3Zfc2FkZHIsCi0JCQkJCSAgICAmc2stPnNrX3Y2X3Jjdl9zYWRkciwKKwkJCQkJICAgIGluZXQ2
X3Jjdl9zYWRkcihzayksCiAJCQkJCSAgICB0Yi0+ZmFzdF9yY3Zfc2FkZHIsCiAJCQkJCSAgICBz
ay0+c2tfcmN2X3NhZGRyLAogCQkJCQkgICAgdGItPmZhc3RfaXB2Nl9vbmx5LAotLSAKMi4xMy41
Cgo=

--_002_EF55EF02AD404F068C074F9F4221BFE6fbcom_--
