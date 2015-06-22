From: Maninder Singh <maninder1.s@samsung.com>
Subject: Re: [RFC PATCH v2] packet: remove handling of tx_ring
Date: Mon, 22 Jun 2015 06:53:06 +0000 (GMT)
Message-ID: <1504484104.41691434955982414.JavaMail.weblogic@ep2mlwas07a>
Reply-To: maninder1.s@samsung.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: base64
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Willem de Bruijn <willemb@google.com>,
	"dborkman@redhat.com" <dborkman@redhat.com>,
	Alexander Drozdov <al.drozdov@gmail.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eyal Birger <eyal.birger@gmail.com>,
	"mst@redhat.com" <mst@redhat.com>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	PANKAJ MISHRA <pankaj.m@samsung.com>
To: Frans Klaver <fransklaver@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:39977 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754258AbbFVGxJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2015 02:53:09 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NQC02WLZ34I7P50@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 22 Jun 2015 15:53:06 +0900 (KST)
MIME-version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGkgRnJhbnMsDQoNCj4+IHYxID0gcmVwbGFjZSBpZigpL0JVRyB3aXRoIEJVR19PTigpIGZvciB0
eF9yaW5nLg0KPj4NCj4+IHYyID0NCj4NCj5JIHdvdWxkIGtlZXAgdGhpcyBiZWxvdyB0aGUgLS0t
LiBUaGVyZSdzIGxpdHRsZSBoaXN0b3JpY2FsIHVzZSBmb3INCj50aGlzIHZlcnNpb24gaW5mb3Jt
YXRpb24gd2hlbiBpdCBnZXRzIG1lcmdlZC4NCj4NCj4+IHJlbW92ZSBoYW5kbGluZyBvZiB0eF9y
aW5nIGluIHByYl9zZXR1cF9yZXRpcmVfYmxrX3RpbWVyDQo+PiBmb3IgVFBBQ0tFVF9WMyBiZWNh
dXNlIGluaXRfcHJiX2JkcWMgaXMgY2FsbGVkIG9ubHkgZm9yIE5VTEwgdHhfcmluZw0KPj4gYW5k
IHRodXMgcHJiX3NldHVwX3JldGlyZV9ibGtfdGltZXIgZm9yIE5VTEwgdHhfcmluZyBvbmx5Lg0K
Pg0KPkknZCBzYXkgdHhfcmluZyBpcyBmYWxzZSwgcmF0aGVyIHRoYW4gTlVMTC4gSXQncyBub3Qg
YSBwb2ludGVyIChoZXJlKS4NCj4NCj4NCj4+IEFuZCBhbHNvIGluIGZ1bmNpdG9uIGluaXRfcHJi
X2JkcWMgdGhlcmUgaXMgbm8gdXNhZ2Ugb2YgdHhfcmluZy4NCj4NCj5zLGZ1bmNpdG9uLGZ1bmN0
aW9uLA0KDQpUaGFua3MgZm9yIGZlZWRiYWNrICwgcGxlYXNlIGNoZWNrIGJlbG93IGNoYW5nZWxv
ZyBpZiBpdCBsb29rcyBvaywNClRoZW4gaSB3aWxsIHNoYXJlIHVwZGF0ZWQgcGF0Y2g6LQ0KDQp2
MSA9IHJlcGxhY2UgaWYoKS9CVUcgd2l0aCBCVUdfT04oKSBmb3IgdHhfcmluZy4NCg0KU2lnbmVk
LW9mZi1ieTogTWFuaW5kZXIgU2luZ2ggPG1hbmluZGVyMS5zQHNhbXN1bmcuY29tPg0KU2lnbmVk
LW9mZi1ieTogRnJhbnMgS2xhdmVyIDxmcmFuc2tsYXZlckBnbWFpbC5jb20+DQotLS0NCkNoYW5n
ZXMgaW4gdjI6DQoNCiBSZW1vdmUgaGFuZGxpbmcgb2YgdHhfcmluZyBpbiBwcmJfc2V0dXBfcmV0
aXJlX2Jsa190aW1lcg0KIGZvciBUUEFDS0VUX1YzIGJlY2F1c2UgaW5pdF9wcmJfYmRxYyBpcyBj
YWxsZWQgb25seSBmb3IgemVybyB0eF9yaW5nIA0KIGFuZCB0aHVzIHByYl9zZXR1cF9yZXRpcmVf
YmxrX3RpbWVyIGZvciB6ZXJvIHR4X3Jpbmcgb25seS4NCg0KIEFuZCBhbHNvIGluIGZ1bmN0b24g
aW5pdF9wcmJfYmRxYyB0aGVyZSBpcyBubyB1c2FnZSBvZiB0eF9yaW5nLg0KIFRodXMgcmVtb3Zp
bmcgdHhfcmluZyBmcm9tIGluaXRfcHJiX2JkcWMuDQoNCiBuZXQvcGFja2V0L2FmX3BhY2tldC5j
IHwgICAxNCArKysrKy0tLS0tLS0tLQ0KIDEgZmlsZSBjaGFuZ2VkLCA1IGluc2VydGlvbnMoKyks
IDkgZGVsZXRpb25zKC0pDQogDQogVGhhbmtzDQogTWFuaW5kZXI=
