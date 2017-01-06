From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 2/7] h8300: put bitsperlong.h in uapi
Date: Fri,  6 Jan 2017 10:43:54 +0100
Message-ID: <1483695839-18660-3-git-send-email-nicolas.dichtel@6wind.com>
References: <bf83da6b-01ef-bf44-b3e1-ca6fc5636818@6wind.com>
 <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
 linux-ia64@vger.kernel.org, linux-doc@vger.kernel.org, airlied@linux.ie,
 linux-fbdev@vger.kernel.org, dri-devel@lists.freedesktop.org,
 linux-mtd@lists.infradead.org, sparclinux@vger.kernel.org,
 linux-arch@vger.kernel.org, linux-s390@vger.kernel.org,
 linux-am33-list@redhat.com, linux-c6x-dev@linux-c6x.org,
 linux-rdma@vger.kernel.org, linux-hexagon@vger.kernel.org,
 linux-sh@vger.kernel.org, coreteam@netfilter.org, fcoe-devel@open-fcoe.org,
 xen-devel@lists.xenproject.org, linux-snps-arc@lists.infradead.org,
 linux-media@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp,
 linux-xtensa@linux-xtensa.org, linux-kbuild@vger.kernel.org,
 adi-buildroot-devel@lists.sourceforge.net, linux-raid@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, openrisc@lists.librecores.org,
 Nicolas Dichtel <nicolas.dichtel@6wind.com>, linux-me
To: arnd@arndb.de
Return-path: <xen-devel-bounces@lists.xen.org>
In-Reply-To: <1483695839-18660-1-git-send-email-nicolas.dichtel@6wind.com>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

VGhpcyBoZWFkZXIgZmlsZSBpcyBleHBvcnRlZCwgdGh1cyBtb3ZlIGl0IHRvIHVhcGkuCgpTaWdu
ZWQtb2ZmLWJ5OiBOaWNvbGFzIERpY2h0ZWwgPG5pY29sYXMuZGljaHRlbEA2d2luZC5jb20+Ci0t
LQogYXJjaC9oODMwMC9pbmNsdWRlL2FzbS9iaXRzcGVybG9uZy5oICAgICAgfCAxMCArLS0tLS0t
LS0tCiBhcmNoL2g4MzAwL2luY2x1ZGUvdWFwaS9hc20vYml0c3BlcmxvbmcuaCB8IDE0ICsrKysr
KysrKysrKysrCiAyIGZpbGVzIGNoYW5nZWQsIDE1IGluc2VydGlvbnMoKyksIDkgZGVsZXRpb25z
KC0pCiBjcmVhdGUgbW9kZSAxMDA2NDQgYXJjaC9oODMwMC9pbmNsdWRlL3VhcGkvYXNtL2JpdHNw
ZXJsb25nLmgKCmRpZmYgLS1naXQgYS9hcmNoL2g4MzAwL2luY2x1ZGUvYXNtL2JpdHNwZXJsb25n
LmggYi9hcmNoL2g4MzAwL2luY2x1ZGUvYXNtL2JpdHNwZXJsb25nLmgKaW5kZXggZTE0MGU0Njcy
OWFjLi5jMGE4ZTJlZTUzMWUgMTAwNjQ0Ci0tLSBhL2FyY2gvaDgzMDAvaW5jbHVkZS9hc20vYml0
c3BlcmxvbmcuaAorKysgYi9hcmNoL2g4MzAwL2luY2x1ZGUvYXNtL2JpdHNwZXJsb25nLmgKQEAg
LTEsMTQgKzEsNiBAQAogI2lmbmRlZiBfX0FTTV9IODMwMF9CSVRTX1BFUl9MT05HCiAjZGVmaW5l
IF9fQVNNX0g4MzAwX0JJVFNfUEVSX0xPTkcKIAotI2luY2x1ZGUgPGFzbS1nZW5lcmljL2JpdHNw
ZXJsb25nLmg+Ci0KLSNpZiAhZGVmaW5lZChfX0FTU0VNQkxZX18pCi0vKiBoODMwMC11bmtub3du
LWxpbnV4IHJlcXVpcmVkIGxvbmcgKi8KLSNkZWZpbmUgX19rZXJuZWxfc2l6ZV90IF9fa2VybmVs
X3NpemVfdAotdHlwZWRlZiB1bnNpZ25lZCBsb25nCV9fa2VybmVsX3NpemVfdDsKLXR5cGVkZWYg
bG9uZwkJX19rZXJuZWxfc3NpemVfdDsKLXR5cGVkZWYgbG9uZwkJX19rZXJuZWxfcHRyZGlmZl90
OwotI2VuZGlmCisjaW5jbHVkZSA8dWFwaS9hc20vYml0c3BlcmxvbmcuaD4KIAogI2VuZGlmIC8q
IF9fQVNNX0g4MzAwX0JJVFNfUEVSX0xPTkcgKi8KZGlmZiAtLWdpdCBhL2FyY2gvaDgzMDAvaW5j
bHVkZS91YXBpL2FzbS9iaXRzcGVybG9uZy5oIGIvYXJjaC9oODMwMC9pbmNsdWRlL3VhcGkvYXNt
L2JpdHNwZXJsb25nLmgKbmV3IGZpbGUgbW9kZSAxMDA2NDQKaW5kZXggMDAwMDAwMDAwMDAwLi5l
NTZjZjcyMzY5YjYKLS0tIC9kZXYvbnVsbAorKysgYi9hcmNoL2g4MzAwL2luY2x1ZGUvdWFwaS9h
c20vYml0c3BlcmxvbmcuaApAQCAtMCwwICsxLDE0IEBACisjaWZuZGVmIF9VQVBJX0FTTV9IODMw
MF9CSVRTX1BFUl9MT05HCisjZGVmaW5lIF9VQVBJX0FTTV9IODMwMF9CSVRTX1BFUl9MT05HCisK
KyNpbmNsdWRlIDxhc20tZ2VuZXJpYy9iaXRzcGVybG9uZy5oPgorCisjaWYgIWRlZmluZWQoX19B
U1NFTUJMWV9fKQorLyogaDgzMDAtdW5rbm93bi1saW51eCByZXF1aXJlZCBsb25nICovCisjZGVm
aW5lIF9fa2VybmVsX3NpemVfdCBfX2tlcm5lbF9zaXplX3QKK3R5cGVkZWYgdW5zaWduZWQgbG9u
ZwlfX2tlcm5lbF9zaXplX3Q7Cit0eXBlZGVmIGxvbmcJCV9fa2VybmVsX3NzaXplX3Q7Cit0eXBl
ZGVmIGxvbmcJCV9fa2VybmVsX3B0cmRpZmZfdDsKKyNlbmRpZgorCisjZW5kaWYgLyogX1VBUElf
QVNNX0g4MzAwX0JJVFNfUEVSX0xPTkcgKi8KLS0gCjIuOC4xCgoKX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX18KWGVuLWRldmVsIG1haWxpbmcgbGlzdApYZW4t
ZGV2ZWxAbGlzdHMueGVuLm9yZwpodHRwczovL2xpc3RzLnhlbi5vcmcveGVuLWRldmVsCg==
