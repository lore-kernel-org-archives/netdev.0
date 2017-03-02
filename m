From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net 0/2] xen-netback: update memory leak fix to
	avoid BUG
Date: Thu, 2 Mar 2017 12:54:24 +0000
Message-ID: <1488459266-29269-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Paul Durrant <paul.durrant@citrix.com>
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

Q29tbWl0IDlhNmNkZjUyYjg1ZSAieGVuLW5ldGJhY2s6IGZpeCBtZW1vcnkgbGVha3Mgb24gWGVu
QnVzIGRpc2Nvbm5lY3QiCmFkZGVkIG1pc3NpbmcgY29kZSB0byBmaXggYSBtZW1vcnkgbGVhayBi
eSBjYWxsaW5nIHZmcmVlKCkgaW4gdGhlCmFwcHJvcHJpYXRlIHBsYWNlLgpVbmZvcnR1bmF0ZWx5
IHN1YnNlcXVlbnQgY29tbWl0IGYxNmYxZGY2NWYxYyAieGVuLW5ldGJhY2s6IHByb3RlY3QKcmVz
b3VyY2UgY2xlYW5pbmcgb24gWGVuQnVzIGRpc2Nvbm5lY3QiIHRoZW4gd3JhcHBlZCB0aGlzIGNh
bGwgdG8gdmZyZWUoKQppbiBhIHNwaW4gbG9jaywgbGVhZGluZyB0byBhIEJVRyBkdWUgdG8gaW5j
b3JyZWN0IGNvbnRleHQuCgpQYXRjaCAjMSBtYWtlcyB0aGUgZXhpc3RpbmcgY29kZSBtb3JlIHJl
YWRhYmxlClBhdGNoICMyIGZpeGVzIHRoZSBwcm9ibGVtCgpQYXVsIER1cnJhbnQgKDIpOgogIHhl
bi1uZXRiYWNrOiBrZWVwIGEgbG9jYWwgcG9pbnRlciBmb3IgdmlmIGluIGJhY2tlbmRfZGlzY29u
bmVjdCgpCiAgeGVuLW5ldGJhY2s6IGRvbid0IHZmcmVlKCkgcXVldWVzIHVuZGVyIHNwaW5sb2Nr
CgogZHJpdmVycy9uZXQveGVuLW5ldGJhY2sveGVuYnVzLmMgfCAzMSArKysrKysrKysrKysrKysr
KysrLS0tLS0tLS0tLS0tCiAxIGZpbGUgY2hhbmdlZCwgMTkgaW5zZXJ0aW9ucygrKSwgMTIgZGVs
ZXRpb25zKC0pCgotLSAKMi4xLjQKCgpfX19fX19fX19fX19fX19fX19fX19fX19fX19fX19fX19f
X19fX19fX19fX19fXwpYZW4tZGV2ZWwgbWFpbGluZyBsaXN0Clhlbi1kZXZlbEBsaXN0cy54ZW4u
b3JnCmh0dHBzOi8vbGlzdHMueGVuLm9yZy94ZW4tZGV2ZWwK
