From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2 02/11] Kbuild: avoid duplicate include path
Date: Wed, 15 Jun 2016 17:45:44 +0200
Message-ID: <20160615154553.3177021-3-arnd@arndb.de>
References: <20160615154553.3177021-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Arnd Bergmann <arnd@arndb.de>, linux-kbuild@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, linux-arm-kernel@lists.infradead.org
To: Michal Marek <mmarek@suse.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
In-Reply-To: <20160615154553.3177021-1-arnd@arndb.de>
List-Unsubscribe: <https://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <https://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <https://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

YXJjaC8kKGhkci1hcmNoKS9pbmNsdWRlL2dlbmVyYXRlZC91YXBpIGlzIGluY2x1ZGVkIHR3aWNl
IGluIHRoZQpoZWFkZXIgc2VhcmNoIHBhdGgsIHdoaWNoIGlzIHVubmVjZXNzYXJ5LCBzbyB0aGlz
IGNoYW5nZXMgdGhlCnRvcC1sZXZlbCBNYWtlZmlsZSB0byBkcm9wIHRoZSBzZWNvbmQgaW5zdGFu
Y2UgYnkgZmlsdGVyaW5nIG91dApldmVyeXRoaW5nIGZyb20gVVNFUklOQ0xVREUgdGhhdCB3YXMg
YWxyZWFkeSBwYXJ0IG9mIExJTlVYSU5DTFVERS4KClRoaXMgc2hvdWxkIGhhdmUgdmVyeSBsaXR0
bGUgZWZmZWN0IG90aGVyIHRoYW4gbWFraW5nIHRoZSAnbWFrZSBWPTEnCm91dHB1dCBzbGlnaHRs
eSBzbWFsbGVyIGFuZCBtYWtpbmcgdGhlIGJ1aWxkIHRpbWUgZmFzdGVyIGJ5IGEgbWluaXNjdWxl
CmFtb3VudCwgYnV0IGl0IHNlZW1zIHRvIGJlIGNsZWFuZXIuCgpTaWduZWQtb2ZmLWJ5OiBBcm5k
IEJlcmdtYW5uIDxhcm5kQGFybmRiLmRlPgotLS0KIE1ha2VmaWxlIHwgNSArKystLQogMSBmaWxl
IGNoYW5nZWQsIDMgaW5zZXJ0aW9ucygrKSwgMiBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9N
YWtlZmlsZSBiL01ha2VmaWxlCmluZGV4IDhiODBhMTUwNmJlMC4uNDUxNTk4NjFlNjQ1IDEwMDY0
NAotLS0gYS9NYWtlZmlsZQorKysgYi9NYWtlZmlsZQpAQCAtMzg5LDggKzM4OSw5IEBAIExJTlVY
SU5DTFVERSAgICA6PSBcCiAJCS1JYXJjaC8kKGhkci1hcmNoKS9pbmNsdWRlL2dlbmVyYXRlZC91
YXBpIFwKIAkJLUlhcmNoLyQoaGRyLWFyY2gpL2luY2x1ZGUvZ2VuZXJhdGVkIFwKIAkJJChpZiAk
KEtCVUlMRF9TUkMpLCAtSSQoc3JjdHJlZSkvaW5jbHVkZSkgXAotCQktSWluY2x1ZGUgXAotCQkk
KFVTRVJJTkNMVURFKQorCQktSWluY2x1ZGUKKworTElOVVhJTkNMVURFCSs9ICQoZmlsdGVyLW91
dCAkKExJTlVYSU5DTFVERSksJChVU0VSSU5DTFVERSkpCiAKIEtCVUlMRF9DUFBGTEFHUyA6PSAt
RF9fS0VSTkVMX18KIAotLSAKMi45LjAKCl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fCmRyaS1kZXZlbCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZy
ZWVkZXNrdG9wLm9yZwpodHRwczovL2xpc3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3Rp
bmZvL2RyaS1kZXZlbAo=
