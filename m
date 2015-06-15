From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH 0/3] ixgbe, ixgbevf: make VF driver check MC promisc enabled
Date: Mon, 15 Jun 2015 10:46:32 +0000
Message-ID: <7F861DC0615E0C47A872E6F3C5FCDDBD05EDEF80@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "nhorman@redhat.com" <nhorman@redhat.com>,
	"jogreene@redhat.com" <jogreene@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	Rony Efraim <ronye@mellanox.com>,
	"David Miller" <davem@davemloft.net>,
	Edward Cree <ecree@solarflare.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([210.143.35.51]:57986 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505AbbFOKtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 06:49:47 -0400
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogSGlyb3NoaSBTaGltYW1vdG8gPGgtc2hpbWFtb3RvQGN0LmpwLm5lYy5jb20+DQoNCk1h
a2UgUEYgcmV0dXJucyBlcnJvciBhZ2FpbnN0IFZGIG11bHRpY2FzdCBwcm9taXNjdW91cyBtb2Rl
IHJlcXVlc3QgZnJvbQ0KdW50cnVzdGVkIFZGLCBhbmQgVkYgaGFuZGxlcyB0aGF0IGVycm9yLg0K
VG8gcmVjb25maWd1cmUsIFBGIHNlbmQgcmVzZXQgdG8gVkYgd2hlbiB0cnVzdCBzdGF0dXMgaXMg
Y2hhbmdlZC4NCg0KVGhpcyBwYXRjaHNldCBpcyBhZ2FpbnN0IHRoZSBsYXRlc3QgSmVmZidzIHRy
ZWUgd2hpY2ggY29udGFpbnMgbXkgVkYNCm11bHRpY2FzdCBwcm9taXNjdW91cyBtb2RlIHBhdGNo
ZXMuDQoNCkhpcm9zaGkgU2hpbWFtb3RvICgzKToNCiAgaXhnYmV2ZjogcmVmYWN0b3IgaXhnYmV2
Zl91cGRhdGVfbWNfYWRkcl9saXN0X3ZmDQogIGl4Z2JlLCBpeGdiZXZmOiBlcnJvciBNQyBwcm9t
aXNjIHVubGVzcyB0cnVzdGVkDQogIGl4Z2JlOiBwaW5nIHRvIHJlc2V0IG9uIGNoYW5naW5nIHRy
dXN0IHN0YXR1cw0KDQogZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvaXhnYmUvaXhnYmVfc3Jp
b3YuYyB8IDMyICsrKysrKysrKysrKy0tLS0tLQ0KIGRyaXZlcnMvbmV0L2V0aGVybmV0L2ludGVs
L2l4Z2JldmYvdmYuYyAgICAgICAgfCA0NiArKysrKysrKysrKysrKysrKysrLS0tLS0tLQ0KIDIg
ZmlsZXMgY2hhbmdlZCwgNTUgaW5zZXJ0aW9ucygrKSwgMjMgZGVsZXRpb25zKC0pDQoNCi0tIA0K
MS44LjMuMQ0KDQo=
