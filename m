From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH 9/9] ARM: berlin: Enable ethernet on Sony NSZ-GS7
Date: Tue, 21 Oct 2014 10:53:47 +0200
Message-ID: <1413881627-21639-10-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1413881627-21639-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: devicetree@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
 Eric Miao <eric.y.miao@gmail.com>, netdev@vger.kernel.org,
 =?UTF-8?q?Antoine=20T=C3=A9nart?= <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, Haojian Zhuang <haojian.zhuang@gmail.com>,
 "David S. Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1413881627-21639-1-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

TWFydmVsbCBCZXJsaW4gQkcyIGJhc2VkIFNvbnkgTlNaLUdTNyBoYXMgb25lIGV0aGVybmV0IGNv
bnRyb2xsZXIKY29ubmVjdGVkIHRvIHJlYXIgUko0NSBqYWNrLiBFbmFibGUgaXQgYnkgZGVmYXVs
dC4KClRlc3RlZC1ieTogQW50b2luZSBUw6luYXJ0IDxhbnRvaW5lLnRlbmFydEBmcmVlLWVsZWN0
cm9ucy5jb20+ClNpZ25lZC1vZmYtYnk6IFNlYmFzdGlhbiBIZXNzZWxiYXJ0aCA8c2ViYXN0aWFu
Lmhlc3NlbGJhcnRoQGdtYWlsLmNvbT4KLS0tCkNjOiAiRGF2aWQgUy4gTWlsbGVyIiA8ZGF2ZW1A
ZGF2ZW1sb2Z0Lm5ldD4KQ2M6ICJBbnRvaW5lIFTDqW5hcnQiIDxhbnRvaW5lLnRlbmFydEBmcmVl
LWVsZWN0cm9ucy5jb20+CkNjOiBGbG9yaWFuIEZhaW5lbGxpIDxmLmZhaW5lbGxpQGdtYWlsLmNv
bT4KQ2M6IEVyaWMgTWlhbyA8ZXJpYy55Lm1pYW9AZ21haWwuY29tPgpDYzogSGFvamlhbiBaaHVh
bmcgPGhhb2ppYW4uemh1YW5nQGdtYWlsLmNvbT4KQ2M6IGxpbnV4LWFybS1rZXJuZWxAbGlzdHMu
aW5mcmFkZWFkLm9yZwpDYzogbmV0ZGV2QHZnZXIua2VybmVsLm9yZwpDYzogZGV2aWNldHJlZUB2
Z2VyLmtlcm5lbC5vcmcKQ2M6IGxpbnV4LWtlcm5lbEB2Z2VyLmtlcm5lbC5vcmcKLS0tCiBhcmNo
L2FybS9ib290L2R0cy9iZXJsaW4yLXNvbnktbnN6LWdzNy5kdHMgfCAyICsrCiAxIGZpbGUgY2hh
bmdlZCwgMiBpbnNlcnRpb25zKCspCgpkaWZmIC0tZ2l0IGEvYXJjaC9hcm0vYm9vdC9kdHMvYmVy
bGluMi1zb255LW5zei1nczcuZHRzIGIvYXJjaC9hcm0vYm9vdC9kdHMvYmVybGluMi1zb255LW5z
ei1nczcuZHRzCmluZGV4IGM3MmJmZDQ2OGQxMC4uMjdmMmYwYWQ3NTYyIDEwMDY0NAotLS0gYS9h
cmNoL2FybS9ib290L2R0cy9iZXJsaW4yLXNvbnktbnN6LWdzNy5kdHMKKysrIGIvYXJjaC9hcm0v
Ym9vdC9kdHMvYmVybGluMi1zb255LW5zei1nczcuZHRzCkBAIC0yNiw0ICsyNiw2IEBACiAJfTsK
IH07CiAKKyZldGgxIHsgc3RhdHVzID0gIm9rYXkiOyB9OworCiAmdWFydDAgeyBzdGF0dXMgPSAi
b2theSI7IH07Ci0tIAoyLjEuMQoKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fCmxpbnV4LWFybS1rZXJuZWwgbWFpbGluZyBsaXN0CmxpbnV4LWFybS1rZXJu
ZWxAbGlzdHMuaW5mcmFkZWFkLm9yZwpodHRwOi8vbGlzdHMuaW5mcmFkZWFkLm9yZy9tYWlsbWFu
L2xpc3RpbmZvL2xpbnV4LWFybS1rZXJuZWwK
