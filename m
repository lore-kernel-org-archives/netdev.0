From: Andrzej Hajda <a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 08/38] openvswitch: fix handling result of
	ipv6_skip_exthdr
Date: Mon, 21 Sep 2015 15:33:40 +0200
Message-ID: <1442842450-29769-9-git-send-email-a.hajda@samsung.com>
References: <1442842450-29769-1-git-send-email-a.hajda@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Bartlomiej Zolnierkiewicz <b.zolnierkie-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrzej Hajda <a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
 Marek Szyprowski <m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-reply-to: <1442842450-29769-1-git-send-email-a.hajda-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

VGhlIGZ1bmN0aW9uIGNhbiByZXR1cm4gbmVnYXRpdmUgdmFsdWUuCgpUaGUgcHJvYmxlbSBoYXMg
YmVlbiBkZXRlY3RlZCB1c2luZyBwcm9wb3NlZCBzZW1hbnRpYyBwYXRjaApzY3JpcHRzL2NvY2Np
bmVsbGUvdGVzdHMvdW5zaWduZWRfbGVzc2VyX3RoYW5femVyby5jb2NjaSBbMV0uCgpbMV06IGh0
dHA6Ly9wZXJtYWxpbmsuZ21hbmUub3JnL2dtYW5lLmxpbnV4Lmtlcm5lbC8yMDM4NTc2CgpTaWdu
ZWQtb2ZmLWJ5OiBBbmRyemVqIEhhamRhIDxhLmhhamRhQHNhbXN1bmcuY29tPgotLS0KIG5ldC9v
cGVudnN3aXRjaC9jb25udHJhY2suYyB8IDIgKy0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlv
bigrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAtLWdpdCBhL25ldC9vcGVudnN3aXRjaC9jb25udHJh
Y2suYyBiL25ldC9vcGVudnN3aXRjaC9jb25udHJhY2suYwppbmRleCAwMDJhNzU1Li5mZGUzMzkx
IDEwMDY0NAotLS0gYS9uZXQvb3BlbnZzd2l0Y2gvY29ubnRyYWNrLmMKKysrIGIvbmV0L29wZW52
c3dpdGNoL2Nvbm50cmFjay5jCkBAIC0yNTMsNyArMjUzLDcgQEAgc3RhdGljIGludCBvdnNfY3Rf
aGVscGVyKHN0cnVjdCBza19idWZmICpza2IsIHUxNiBwcm90bykKIAljb25zdCBzdHJ1Y3QgbmZf
Y29ubnRyYWNrX2hlbHBlciAqaGVscGVyOwogCWNvbnN0IHN0cnVjdCBuZl9jb25uX2hlbHAgKmhl
bHA7CiAJZW51bSBpcF9jb25udHJhY2tfaW5mbyBjdGluZm87Ci0JdW5zaWduZWQgaW50IHByb3Rv
ZmY7CisJaW50IHByb3RvZmY7CiAJc3RydWN0IG5mX2Nvbm4gKmN0OwogCiAJY3QgPSBuZl9jdF9n
ZXQoc2tiLCAmY3RpbmZvKTsKLS0gCjEuOS4xCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fXwpkZXYgbWFpbGluZyBsaXN0CmRldkBvcGVudnN3aXRjaC5vcmcK
aHR0cDovL29wZW52c3dpdGNoLm9yZy9tYWlsbWFuL2xpc3RpbmZvL2Rldgo=
