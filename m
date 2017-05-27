From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH] e1000e: use disable_hardirq() also for MSIX vectors in
 e1000_netpoll()
Date: Sat, 27 May 2017 01:21:36 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B8C5FC04C@ORSMSX101.amr.corp.intel.com>
References: <149517832870.37403.16008624383220981105.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Dave Jones <davej@codemonkey.org.uk>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:34320 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S944978AbdE0BVi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 May 2017 21:21:38 -0400
In-Reply-To: <149517832870.37403.16008624383220981105.stgit@buzz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBGcm9tOiBuZXRkZXYtb3duZXJAdmdlci5rZXJuZWwub3JnIFttYWlsdG86bmV0ZGV2LQ0KPiBv
d25lckB2Z2VyLmtlcm5lbC5vcmddIE9uIEJlaGFsZiBPZiBLb25zdGFudGluIEtobGVibmlrb3YN
Cj4gU2VudDogRnJpZGF5LCBNYXkgMTksIDIwMTcgMTI6MTkgQU0NCj4gVG86IG5ldGRldkB2Z2Vy
Lmtlcm5lbC5vcmc7IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnOyBLaXJzaGVyLCBK
ZWZmcmV5DQo+IFQgPGplZmZyZXkudC5raXJzaGVyQGludGVsLmNvbT4NCj4gQ2M6IERhdmUgSm9u
ZXMgPGRhdmVqQGNvZGVtb25rZXkub3JnLnVrPjsgV0FORyBDb25nDQo+IDx4aXlvdS53YW5nY29u
Z0BnbWFpbC5jb20+OyBEYXZpZCBTLiBNaWxsZXIgPGRhdmVtQGRhdmVtbG9mdC5uZXQ+Ow0KPiBT
YWJyaW5hIER1YnJvY2EgPHNkQHF1ZWFzeXNuYWlsLm5ldD4NCj4gU3ViamVjdDogW1BBVENIXSBl
MTAwMGU6IHVzZSBkaXNhYmxlX2hhcmRpcnEoKSBhbHNvIGZvciBNU0lYIHZlY3RvcnMgaW4NCj4g
ZTEwMDBfbmV0cG9sbCgpDQo+IA0KPiBSZXBsYWNlIGRpc2FibGVfaXJxKCkgd2hpY2ggd2FpdHMg
Zm9yIHRocmVhZGVkIGlycSBoYW5kbGVycyB3aXRoDQo+IGRpc2FibGVfaGFyZGlycSgpIHdoaWNo
IHdhaXRzIG9ubHkgZm9yIGhhcmRpcnEgcGFydC4NCj4gDQo+IFNpZ25lZC1vZmYtYnk6IEtvbnN0
YW50aW4gS2hsZWJuaWtvdiA8a2hsZWJuaWtvdkB5YW5kZXgtdGVhbS5ydT4NCj4gRml4ZXM6IDMx
MTE5MTI5NzEyNSAoImUxMDAwOiB1c2UgZGlzYWJsZV9oYXJkaXJxKCkgZm9yIGUxMDAwX25ldHBv
bGwoKSIpDQo+IC0tLQ0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvaW50ZWwvZTEwMDBlL25ldGRl
di5jIHwgICAxMiArKysrKystLS0tLS0NCj4gIDEgZmlsZSBjaGFuZ2VkLCA2IGluc2VydGlvbnMo
KyksIDYgZGVsZXRpb25zKC0pDQoNClRlc3RlZC1ieTogQWFyb24gQnJvd24gPGFhcm9uLmYuYnJv
d25AaW50ZWwuY29tPg0KDQo=
