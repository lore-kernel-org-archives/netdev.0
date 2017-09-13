From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 06/10] drivers:ethernet: return -ENOMEM on allocation
 failure.
Date: Wed, 13 Sep 2017 14:16:28 +0200
Message-ID: <20170913121628.GB11820@lunn.ch>
References: <1505287939-14106-1-git-send-email-allen.lkml@gmail.com>
 <1505287939-14106-6-git-send-email-allen.lkml@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: linux-fbdev@vger.kernel.org, linux-scsi@vger.kernel.org,
 nouveau@lists.freedesktop.org, linux-kernel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, target-devel@vger.kernel.org,
 linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
 linux-btrfs@vger.kernel.org, MPT-FusionLinux.pdl@broadcom.com,
 megaraidlinux.pdl@broadcom.com
To: Allen Pais <allen.lkml@gmail.com>
Return-path: <dri-devel-bounces@lists.freedesktop.org>
Content-Disposition: inline
In-Reply-To: <1505287939-14106-6-git-send-email-allen.lkml@gmail.com>
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

T24gV2VkLCBTZXAgMTMsIDIwMTcgYXQgMDE6MDI6MTVQTSArMDUzMCwgQWxsZW4gUGFpcyB3cm90
ZToKPiBTaWduZWQtb2ZmLWJ5OiBBbGxlbiBQYWlzIDxhbGxlbi5sa21sQGdtYWlsLmNvbT4KPiAt
LS0KPiAgZHJpdmVycy9uZXQvZXRoZXJuZXQvc3VuL2Nhc3NpbmkuYyB8IDIgKy0KPiAgMSBmaWxl
IGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pCj4gCj4gZGlmZiAtLWdpdCBh
L2RyaXZlcnMvbmV0L2V0aGVybmV0L3N1bi9jYXNzaW5pLmMgYi9kcml2ZXJzL25ldC9ldGhlcm5l
dC9zdW4vY2Fzc2luaS5jCj4gaW5kZXggMzgyOTkzYy4uZmMwZWEzYSAxMDA2NDQKPiAtLS0gYS9k
cml2ZXJzL25ldC9ldGhlcm5ldC9zdW4vY2Fzc2luaS5jCj4gKysrIGIvZHJpdmVycy9uZXQvZXRo
ZXJuZXQvc3VuL2Nhc3NpbmkuYwo+IEBAIC0zOTg0LDcgKzM5ODQsNyBAQCBzdGF0aWMgaW5saW5l
IGludCBjYXNfYWxsb2NfcnhfZGVzYyhzdHJ1Y3QgY2FzICpjcCwgaW50IHJpbmcpCj4gIAlzaXpl
ID0gUlhfREVTQ19SSU5HTl9TSVpFKHJpbmcpOwo+ICAJZm9yIChpID0gMDsgaSA8IHNpemU7IGkr
Kykgewo+ICAJCWlmICgocGFnZVtpXSA9IGNhc19wYWdlX2FsbG9jKGNwLCBHRlBfS0VSTkVMKSkg
PT0gTlVMTCkKPiAtCQkJcmV0dXJuIC0xOwo+ICsJCQlyZXR1cm4gLUVOT01FTTsKPiAgCX0KPiAg
CXJldHVybiAwOwo+ICB9CgpzdGF0aWMgaW50IGNhc19hbGxvY19yeGRzKHN0cnVjdCBjYXMgKmNw
KQp7CglpbnQgaTsKCglmb3IgKGkgPSAwOyBpIDwgTl9SWF9ERVNDX1JJTkdTOyBpKyspIHsKCQlp
ZiAoY2FzX2FsbG9jX3J4X2Rlc2MoY3AsIGkpIDwgMCkgewoJICAgICAgIAkJY2FzX2ZyZWVfcnhk
cyhjcCk7CgkJCXJldHVybiAtMTsKCQl9Cgl9CglyZXR1cm4gMDsKfQoKQWdhaW4sIHlvdXIgY2hh
bmdlIGlzIGNvcnJlY3QsIGJ1dCBpbiB0aGUgZW5kIHRoZSB2YWx1ZSBpcyBub3QgdXNlZC4KQW5k
IGlmIHlvdSBmaXggaXQgYXQgdGhlIGNhc19hbGxvY19yeGRzIGxldmVsLCB5b3UgYWxzbyBuZWVk
IGEgZml4IGF0CnRoZSBuZXh0IGxldmVsIHVwOgoKCWVyciA9IC1FTk9NRU07CglpZiAoY2FzX3R4
X3RpbnlfYWxsb2MoY3ApIDwgMCkKCQlnb3RvIGVycl91bmxvY2s7CgoJLyogYWxsb2MgcnggZGVz
Y3JpcHRvcnMgKi8KCWlmIChjYXNfYWxsb2NfcnhkcyhjcCkgPCAwKQoJCWdvdG8gZXJyX3R4X3Rp
bnk7CgphZ2FpbiwgdGhlIHJldHVybiB2YWx1ZSBpcyBkaXNjYXJkZWQuCgogICAgICAgQW5kcmV3
Cl9fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fCmRyaS1kZXZl
bCBtYWlsaW5nIGxpc3QKZHJpLWRldmVsQGxpc3RzLmZyZWVkZXNrdG9wLm9yZwpodHRwczovL2xp
c3RzLmZyZWVkZXNrdG9wLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2RyaS1kZXZlbAo=
