From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: net.git: Call-trace after "Merge branch 'netlink_multicast'"
Date: Sun, 28 Dec 2014 10:34:51 +0100
Message-ID: <CA+icZUUO5fkmdevyhutYU6=2vBACN0Nr3WA+DMssfhy5xfsrbQ@mail.gmail.com>
References: <CA+icZUVkNHBqCn66onJP9i5vfVzHR9mdSFXyiBFyjhkrySrSzQ@mail.gmail.com>
	<CA+icZUWFq0FT5QQThKeeVw4=-41R7W0Q7zv53ZCY9=B6AJvf7w@mail.gmail.com>
	<CA+icZUU1-o7m9iYNpHyitpbS8W=+mk-ZbBXiK2Zgow2TDnBo1Q@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001a11c23d2839b5c3050b4378e6
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:40541 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750795AbaL1Jew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Dec 2014 04:34:52 -0500
Received: by mail-wg0-f41.google.com with SMTP id y19so16968831wgg.14
        for <netdev@vger.kernel.org>; Sun, 28 Dec 2014 01:34:51 -0800 (PST)
In-Reply-To: <CA+icZUU1-o7m9iYNpHyitpbS8W=+mk-ZbBXiK2Zgow2TDnBo1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001a11c23d2839b5c3050b4378e6
Content-Type: text/plain; charset=UTF-8

On Sun, Dec 28, 2014 at 8:54 AM, Sedat Dilek <sedat.dilek@gmail.com> wrote:
> Just a small thing, if you look at this...
>
> With gcc-4.9.2 I see this warning in my logs...
>
> net/netlink/genetlink.c: In function 'genl_bind':
> net/netlink/genetlink.c:1018:2: warning: 'err' may be used
> uninitialized in this function [-Wmaybe-uninitialized]
>

Attached patch fixes the issue for me.

- Sedat -

--001a11c23d2839b5c3050b4378e6
Content-Type: text/x-diff; charset=US-ASCII;
	name="0002-genetlink-Fix-uninitialized-err-variable-in-genl_bin.patch"
Content-Disposition: attachment;
	filename="0002-genetlink-Fix-uninitialized-err-variable-in-genl_bin.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_i48803ay0

RnJvbSBhZjNlYWE3YTc4NGJlMjNkYjE0YTRhMGY1MDlkZWQ0NzRlNmUwODUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTZWRhdCBEaWxlayA8c2VkYXQuZGlsZWtAZ21haWwuY29tPgpE
YXRlOiBTdW4sIDI4IERlYyAyMDE0IDA5OjIxOjEyICswMTAwClN1YmplY3Q6IFtQQVRDSF0gZ2Vu
ZXRsaW5rOiBGaXggdW5pbml0aWFsaXplZCBlcnIgdmFyaWFibGUgaW4gZ2VubF9iaW5kKCkKClRo
aXMgZml4ZXMgdGhlIGZvbGxvd2luZyBjb21waWxlcmUgKGhlcmU6IGdjYy00LjkpIHdhcm5pbmc6
CgpuZXQvbmV0bGluay9nZW5ldGxpbmsuYzogSW4gZnVuY3Rpb24gJ2dlbmxfYmluZCc6Cm5ldC9u
ZXRsaW5rL2dlbmV0bGluay5jOjEwMTg6Mjogd2FybmluZzogJ2VycicgbWF5IGJlIHVzZWQgdW5p
bml0aWFsaXplZCBpbiB0aGlzIGZ1bmN0aW9uIFstV21heWJlLXVuaW5pdGlhbGl6ZWRdCgpDQzog
Sm9oYW5uZXMgQmVyZyA8am9oYW5uZXMuYmVyZ0BpbnRlbC5jb20+CkNDOiAiRGF2aWQgUy4gTWls
bGVyIiA8ZGF2ZW1AZGF2ZW1sb2Z0Lm5ldD4KQ0M6ICJsaW51eC1uZXRkZXYiIDxuZXRkZXZAdmdl
ci5rZXJuZWwub3JnPgpGaXhlczogYzM4MGQ5YTdhZmZmICgiZ2VuZXRsaW5rOiBwYXNzIG11bHRp
Y2FzdCBiaW5kL3VuYmluZCB0byBmYW1pbGllcyIpClJlcG9ydGVkLWJ5OiBTZWRhdCBEaWxlayA8
c2VkYXQuZGlsZWtAZ21haWwuY29tPgpTaWduZWQtb2ZmLWJ5OiBTZWRhdCBEaWxlayA8c2VkYXQu
ZGlsZWtAZ21haWwuY29tPgotLS0KIG5ldC9uZXRsaW5rL2dlbmV0bGluay5jIHwgMiArLQogMSBm
aWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0aW9uKC0pCgpkaWZmIC0tZ2l0IGEv
bmV0L25ldGxpbmsvZ2VuZXRsaW5rLmMgYi9uZXQvbmV0bGluay9nZW5ldGxpbmsuYwppbmRleCA1
Y2ZiY2VhLi40NGFkNmUzIDEwMDY0NAotLS0gYS9uZXQvbmV0bGluay9nZW5ldGxpbmsuYworKysg
Yi9uZXQvbmV0bGluay9nZW5ldGxpbmsuYwpAQCAtOTg1LDcgKzk4NSw3IEBAIHN0YXRpYyBzdHJ1
Y3QgZ2VubF9tdWx0aWNhc3RfZ3JvdXAgZ2VubF9jdHJsX2dyb3Vwc1tdID0gewogCiBzdGF0aWMg
aW50IGdlbmxfYmluZChzdHJ1Y3QgbmV0ICpuZXQsIGludCBncm91cCkKIHsKLQlpbnQgaSwgZXJy
OworCWludCBlcnIgPSAwLCBpOwogCWJvb2wgZm91bmQgPSBmYWxzZTsKIAogCWRvd25fcmVhZCgm
Y2JfbG9jayk7Ci0tIAoyLjIuMQoK
--001a11c23d2839b5c3050b4378e6--
