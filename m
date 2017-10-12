From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [Nouveau] [PATCH 03/10] driver:gpu: return -ENOMEM on allocation
 failure.
Date: Thu, 12 Oct 2017 19:55:41 +0200
Message-ID: <20171012175541.5jh3ovdzpyj5fflv@phenom.ffwll.local>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
 <1505287939-14106-3-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-fbdev@vger.kernel.org, linux-scsi@vger.kernel.org,
 nouveau@lists.freedesktop.org, megaraidlinux.pdl@broadcom.com,
 linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
 target-devel@vger.kernel.org, linux-crypto@vger.kernel.org,
 netdev@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com,
 linux-btrfs@vger.kernel.org
To: Allen Pais <allen.lkml@gmail.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <1505287939-14106-3-git-send-email-allen.lkml@gmail.com>
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

T24gV2VkLCBTZXAgMTMsIDIwMTcgYXQgMDE6MDI6MTJQTSArMDUzMCwgQWxsZW4gUGFpcyB3cm90
ZToKPiBTaWduZWQtb2ZmLWJ5OiBBbGxlbiBQYWlzIDxhbGxlbi5sa21sQGdtYWlsLmNvbT4KCkFw
cGxpZWQgdG8gZHJtLW1pc2MtbmV4dCwgdGhhbmtzLgotRGFuaWVsCgo+IC0tLQo+ICBkcml2ZXJz
L2dwdS9kcm0vZ21hNTAwL21pZF9iaW9zLmMgfCAyICstCj4gIDEgZmlsZSBjaGFuZ2VkLCAxIGlu
c2VydGlvbigrKSwgMSBkZWxldGlvbigtKQo+IAo+IGRpZmYgLS1naXQgYS9kcml2ZXJzL2dwdS9k
cm0vZ21hNTAwL21pZF9iaW9zLmMgYi9kcml2ZXJzL2dwdS9kcm0vZ21hNTAwL21pZF9iaW9zLmMK
PiBpbmRleCBkNzVlY2IzLi4xZmExNjMzIDEwMDY0NAo+IC0tLSBhL2RyaXZlcnMvZ3B1L2RybS9n
bWE1MDAvbWlkX2Jpb3MuYwo+ICsrKyBiL2RyaXZlcnMvZ3B1L2RybS9nbWE1MDAvbWlkX2Jpb3Mu
Ywo+IEBAIC0yMzcsNyArMjM3LDcgQEAgc3RhdGljIGludCBtaWRfZ2V0X3ZidF9kYXRhX3IxMChz
dHJ1Y3QgZHJtX3BzYl9wcml2YXRlICpkZXZfcHJpdiwgdTMyIGFkZHIpCj4gIAo+ICAJZ2N0ID0g
a21hbGxvYyhzaXplb2YoKmdjdCkgKiB2YnQucGFuZWxfY291bnQsIEdGUF9LRVJORUwpOwo+ICAJ
aWYgKCFnY3QpCj4gLQkJcmV0dXJuIC0xOwo+ICsJCXJldHVybiAtRU5PTUVNOwo+ICAKPiAgCWdj
dF92aXJ0dWFsID0gaW9yZW1hcChhZGRyICsgc2l6ZW9mKHZidCksCj4gIAkJCXNpemVvZigqZ2N0
KSAqIHZidC5wYW5lbF9jb3VudCk7Cj4gLS0gCj4gMi43LjQKPiAKPiBfX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwo+IE5vdXZlYXUgbWFpbGluZyBsaXN0Cj4g
Tm91dmVhdUBsaXN0cy5mcmVlZGVza3RvcC5vcmcKPiBodHRwczovL2xpc3RzLmZyZWVkZXNrdG9w
Lm9yZy9tYWlsbWFuL2xpc3RpbmZvL25vdXZlYXUKCi0tIApEYW5pZWwgVmV0dGVyClNvZnR3YXJl
IEVuZ2luZWVyLCBJbnRlbCBDb3Jwb3JhdGlvbgpodHRwOi8vYmxvZy5mZndsbC5jaApfX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fXwpkcmktZGV2ZWwgbWFpbGlu
ZyBsaXN0CmRyaS1kZXZlbEBsaXN0cy5mcmVlZGVza3RvcC5vcmcKaHR0cHM6Ly9saXN0cy5mcmVl
ZGVza3RvcC5vcmcvbWFpbG1hbi9saXN0aW5mby9kcmktZGV2ZWwK
