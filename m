From: "Andriy Korud" <a.korud@vector.com.pl>
Subject: PCI fix for some platforms
Date: Wed, 30 Jun 2004 10:52:31 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <80908CC5B2C9DB47AAF8C77892FCB44315F7C9@lion.vector.com.pl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----_=_NextPart_001_01C45E7F.9408E889"
Cc: <prism54-private@prism54.org>
Return-path: <netdev-bounce@oss.sgi.com>
content-class: urn:content-classes:message
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

------_=_NextPart_001_01C45E7F.9408E889
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable

Hi,
i've noticed that on some platforms (noticed on PPC/XScale embedded) PCI =
cacheline size is not initialized properly and therefore card uses slow =
"PCI read memory" command instead of optimal "PCI read memory line", =
which cause serious bendwidth limitations in case of 3+ cards on single =
PCI bus.

Attached patch that fix this issue - please merge review.

regards,

--

Andriy Korud

=20



------_=_NextPart_001_01C45E7F.9408E889
Content-Type: text/x-diff;
	name="pci-fix.patch"
Content-Transfer-Encoding: base64
Content-Description: pci-fix.patch
Content-Disposition: attachment;
	filename="pci-fix.patch"

ZGlmZiAtdXIgcHJpc201NC1jdnMtbGF0ZXN0L2tzcmMvaXNscGNpX2Rldi5jIHByaXNtNTQtY3Zz
LWxhdGVzdC1maXgva3NyYy9pc2xwY2lfZGV2LmMKLS0tIHByaXNtNTQtY3ZzLWxhdGVzdC9rc3Jj
L2lzbHBjaV9kZXYuYwkyMDA0LTA1LTI5IDE4OjA2OjQ5LjAwMDAwMDAwMCArMDMwMAorKysgcHJp
c201NC1jdnMtbGF0ZXN0LWZpeC9rc3JjL2lzbHBjaV9kZXYuYwkyMDA0LTA2LTI5IDE4OjUyOjAy
LjAwNjUyMDMwNCArMDMwMApAQCAtNzczLDYgKzc3Myw3IEBACiBzdHJ1Y3QgbmV0X2RldmljZSAq
CiBpc2xwY2lfc2V0dXAoc3RydWN0IHBjaV9kZXYgKnBkZXYpCiB7CisJdV9pbnQ4X3QgY3o7CiAJ
aXNscGNpX3ByaXZhdGUgKnByaXY7CiAJc3RydWN0IG5ldF9kZXZpY2UgKm5kZXYgPSBhbGxvY19l
dGhlcmRldihzaXplb2YgKGlzbHBjaV9wcml2YXRlKSk7CiAKQEAgLTc4NSw2ICs3ODYsMTIgQEAK
IAlTRVRfTkVUREVWX0RFVihuZGV2LCAmcGRldi0+ZGV2KTsKICNlbmRpZgogCisJcGNpX3JlYWRf
Y29uZmlnX2J5dGUocGRldiwgUENJX0NBQ0hFX0xJTkVfU0laRSwgJmNzeik7CisgICAgICAgIGlm
IChjc3ogPT0gMCkgeworCQljc3ogPSBMMV9DQUNIRV9CWVRFUyAvIHNpemVvZih1X2ludDMyX3Qp
OworCQlwY2lfd3JpdGVfY29uZmlnX2J5dGUocGRldiwgUENJX0NBQ0hFX0xJTkVfU0laRSwgY3N6
KTsKKwl9CisKIAkvKiBzZXR1cCB0aGUgc3RydWN0dXJlIG1lbWJlcnMgKi8KIAluZGV2LT5iYXNl
X2FkZHIgPSBwY2lfcmVzb3VyY2Vfc3RhcnQocGRldiwgMCk7CiAJbmRldi0+aXJxID0gcGRldi0+
aXJxOwo=

------_=_NextPart_001_01C45E7F.9408E889--
