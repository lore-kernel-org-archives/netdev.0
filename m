From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 6/8] mtd: replace CONFIG_8xx by CONFIG_PPC_8xx
Date: Thu, 12 Mar 2015 16:24:04 +0100 (CET)
Message-ID: <20150312152404.D6C391A2421@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-fbdev@vger.kernel.org, linux-serial@vger.kernel.org,
 user-mode-linux-devel@lists.sourceforge.net, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mtd@lists.infradead.org,
 user-mode-linux-user@lists.sourceforge.net, linuxppc-dev@lists.ozlabs.org
To: David Woodhouse <dwmw2@infradead.org>,
 Brian Norris <computersforpeace@gmail.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

VHdvIGNvbmZpZyBvcHRpb25zIGV4aXN0IHRvIGRlZmluZSBwb3dlcnBjIE1QQzh4eDoKKiBDT05G
SUdfUFBDXzh4eAoqIENPTkZJR184eHgKSW4gYWRkaXRpb24sIENPTkZJR19QUENfOHh4IGFsc28g
ZGVmaW5lcyBDT05GSUdfQ1BNMSBhcwpjb21tdW5pY2F0aW9uIGNvLXByb2Nlc3NvcgoKYXJjaC9w
b3dlcnBjL3BsYXRmb3Jtcy9LY29uZmlnLmNwdXR5cGUgaGFzIGNvbnRhaW5lZCB0aGUgZm9sbG93
aW5nCmNvbW1lbnQgYWJvdXQgQ09ORklHXzh4eCBpdGVtIGZvciBzb21lIHllYXJzOgoiIyB0aGlz
IGlzIHRlbXAgdG8gaGFuZGxlIGNvbXBhdCB3aXRoIGFyY2g9cHBjIgoKSXQgbG9va3MgbGlrZSBu
b3QgbWFueSBwbGFjZXMgc3RpbGwgaGF2ZSB0aGF0IG9sZCBDT05GSUdfOHh4IHVzZWQsCnNvIGl0
IGlzIGxpa2VseSB0byBiZSBhIGdvb2QgdGltZSB0byBnZXQgcmlkIG9mIGl0IGNvbXBsZXRlbHkg
PwoKU2lnbmVkLW9mZi1ieTogQ2hyaXN0b3BoZSBMZXJveSA8Y2hyaXN0b3BoZS5sZXJveUBjLXMu
ZnI+CgotLS0KIGRyaXZlcnMvbXRkL21hcHMvS2NvbmZpZyB8IDIgKy0KIDEgZmlsZSBjaGFuZ2Vk
LCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL2RyaXZlcnMvbXRk
L21hcHMvS2NvbmZpZyBiL2RyaXZlcnMvbXRkL21hcHMvS2NvbmZpZwppbmRleCBiYTgwMWQyLi5l
NzE1YWU5IDEwMDY0NAotLS0gYS9kcml2ZXJzL210ZC9tYXBzL0tjb25maWcKKysrIGIvZHJpdmVy
cy9tdGQvbWFwcy9LY29uZmlnCkBAIC0yNDIsNyArMjQyLDcgQEAgY29uZmlnIE1URF9MNDQwR1gK
IAogY29uZmlnIE1URF9DRklfRkxBR0FETQogCXRyaXN0YXRlICJDRkkgRmxhc2ggZGV2aWNlIG1h
cHBpbmcgb24gRmxhZ2FETSIKLQlkZXBlbmRzIG9uIDh4eCAmJiBNVERfQ0ZJCisJZGVwZW5kcyBv
biBQUENfOHh4ICYmIE1URF9DRkkKIAloZWxwCiAJICBNYXBwaW5nIGZvciB0aGUgRmxhZ2EgZGln
aXRhbCBtb2R1bGUuIElmIHlvdSBkb24ndCBoYXZlIG9uZSwgaWdub3JlCiAJICB0aGlzIHNldHRp
bmcuCi0tIAoyLjEuMAoKX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX18KTGludXhwcGMtZGV2IG1haWxpbmcgbGlzdApMaW51eHBwYy1kZXZAbGlzdHMub3psYWJz
Lm9yZwpodHRwczovL2xpc3RzLm96bGFicy5vcmcvbGlzdGluZm8vbGludXhwcGMtZGV2
