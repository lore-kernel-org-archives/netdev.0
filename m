From: Anoob Soman <anoob.soman@citrix.com>
Subject: [PATCH net] xen-netback: Use GFP_ATOMIC to allocate hash
Date: Thu, 2 Mar 2017 10:50:20 +0000
Message-ID: <1488451820-4759-1-git-send-email-anoob.soman@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: paul.durrant@citrix.com, wei.liu2@citrix.com,
 Anoob Soman <anoob.soman@citrix.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <xen-devel-bounces@lists.xen.org>
List-Unsubscribe: <https://lists.xen.org/cgi-bin/mailman/options/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xen.org>
List-Help: <mailto:xen-devel-request@lists.xen.org?subject=help>
List-Subscribe: <https://lists.xen.org/cgi-bin/mailman/listinfo/xen-devel>,
 <mailto:xen-devel-request@lists.xen.org?subject=subscribe>
Errors-To: xen-devel-bounces@lists.xen.org
Sender: "Xen-devel" <xen-devel-bounces@lists.xen.org>
List-Id: netdev.vger.kernel.org

QWxsb2NhdGlvbiBvZiBuZXdfaGFzaCwgaW5zaWRlIHhlbnZpZl9uZXdfaGFzaCgpLCBhbHdheXMg
aGFwcGVuCmluIHNvZnRpcnEgY29udGV4dCwgc28gdXNlIEdGUF9BVE9NSUMgaW5zdGVhZCBvZiBH
RlBfS0VSTkVMIGZvciBuZXcKaGFzaCBhbGxvY2F0aW9uLgoKU2lnbmVkLW9mZi1ieTogQW5vb2Ig
U29tYW4gPGFub29iLnNvbWFuQGNpdHJpeC5jb20+Ci0tLQogZHJpdmVycy9uZXQveGVuLW5ldGJh
Y2svaGFzaC5jIHwgMiArLQogMSBmaWxlIGNoYW5nZWQsIDEgaW5zZXJ0aW9uKCspLCAxIGRlbGV0
aW9uKC0pCgpkaWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQveGVuLW5ldGJhY2svaGFzaC5jIGIvZHJp
dmVycy9uZXQveGVuLW5ldGJhY2svaGFzaC5jCmluZGV4IGU4YzVkZGQuLjNjNGM1OGIgMTAwNjQ0
Ci0tLSBhL2RyaXZlcnMvbmV0L3hlbi1uZXRiYWNrL2hhc2guYworKysgYi9kcml2ZXJzL25ldC94
ZW4tbmV0YmFjay9oYXNoLmMKQEAgLTM5LDcgKzM5LDcgQEAgc3RhdGljIHZvaWQgeGVudmlmX2Fk
ZF9oYXNoKHN0cnVjdCB4ZW52aWYgKnZpZiwgY29uc3QgdTggKnRhZywKIAl1bnNpZ25lZCBsb25n
IGZsYWdzOwogCWJvb2wgZm91bmQ7CiAKLQluZXcgPSBrbWFsbG9jKHNpemVvZigqZW50cnkpLCBH
RlBfS0VSTkVMKTsKKwluZXcgPSBrbWFsbG9jKHNpemVvZigqZW50cnkpLCBHRlBfQVRPTUlDKTsK
IAlpZiAoIW5ldykKIAkJcmV0dXJuOwogCi0tIAoyLjcuNAoKCl9fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fX19fX19fX19fX19fX19fClhlbi1kZXZlbCBtYWlsaW5nIGxpc3QKWGVuLWRl
dmVsQGxpc3RzLnhlbi5vcmcKaHR0cHM6Ly9saXN0cy54ZW4ub3JnL3hlbi1kZXZlbAo=
