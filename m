From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: [PATCH] TCP Compound: dwnd=0 on ssthresh
Date: Wed, 5 Jul 2006 17:29:11 +0200
Message-ID: <8dd26e70607050829y4fbafdb6teec54874a11ed275@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_175516_19355983.1152113351923"
Cc: "Francesco Vacirca" <francesco@net.infocom.uniroma1.it>,
	"Andrea Baiocchi" <andrea.baiocchi@uniroma1.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:12556 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S964901AbWGEP3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 11:29:13 -0400
Received: by nf-out-0910.google.com with SMTP id a4so1271023nfc
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2006 08:29:12 -0700 (PDT)
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_175516_19355983.1152113351923
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

In the TCP Compound article used as a reference for the implementation, we read:
"If a retransmission timeout occurs, dwnd should be reset to zero and
the delay-based component is disabled." at page 5 of
ftp://ftp.research.microsoft.com/pub/tr/TR-2005-86.pdf

The attached patch implements this requirement.

Regards,
Angelo P. Castellani

------=_Part_175516_19355983.1152113351923
Content-Type: text/x-patch; name=no_dwnd_on_ssthresh.diff;
	charset=ISO-8859-1
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ep9uiwc5
Content-Disposition: attachment; filename="no_dwnd_on_ssthresh.diff"

ZGlmZiAtdXJkIGEvbmV0L2lwdjQvdGNwX2NvbXBvdW5kLmMgYi9uZXQvaXB2NC90Y3BfY29tcG91
bmQuYwotLS0gYS9uZXQvaXB2NC90Y3BfY29tcG91bmQuYwkyMDA2LTA3LTA1IDE3OjE5OjI4LjAw
MDAwMDAwMCArMDIwMAorKysgYi9uZXQvaXB2NC90Y3BfY29tcG91bmQuYwkyMDA2LTA3LTA1IDE3
OjIwOjQyLjAwMDAwMDAwMCArMDIwMApAQCAtMjIxLDEyICsyMjEsOSBAQAogCQl0Y3BfY29tcG91
bmRfaW5pdChzayk7CiB9CiAKLXN0YXRpYyB2b2lkIHRjcF9jb21wb3VuZF9jb25nX2F2b2lkKHN0
cnVjdCBzb2NrICpzaywgdTMyIGFjaywKLQkJCQkgICAgdTMyIHNlcV9ydHQsIHUzMiBpbl9mbGln
aHQsIGludCBmbGFnKQoteworc3RhdGljIGlubGluZSB2b2lkIHRjcF9jb21wb3VuZF9zeW5jaChz
dHJ1Y3Qgc29jayAqc2spIHsKIAlzdHJ1Y3QgdGNwX3NvY2sgKnRwID0gdGNwX3NrKHNrKTsKIAlz
dHJ1Y3QgY29tcG91bmQgKnZlZ2FzID0gaW5ldF9jc2tfY2Eoc2spOwotCXU4IGluYyA9IDA7CiAK
IAlpZiAodmVnYXMtPmN3bmQgKyB2ZWdhcy0+ZHduZCA+IHRwLT5zbmRfY3duZCkgewogCQlpZiAo
dmVnYXMtPmN3bmQgPiB0cC0+c25kX2N3bmQgfHwgdmVnYXMtPmR3bmQgPiB0cC0+c25kX2N3bmQp
IHsKQEAgLTIzNCw5ICsyMzEsMTkgQEAKIAkJCXZlZ2FzLT5kd25kID0gMDsKIAkJfSBlbHNlCiAJ
CQl2ZWdhcy0+Y3duZCA9IHRwLT5zbmRfY3duZCAtIHZlZ2FzLT5kd25kOwotCiAJfQogCit9CisK
K3N0YXRpYyB2b2lkIHRjcF9jb21wb3VuZF9jb25nX2F2b2lkKHN0cnVjdCBzb2NrICpzaywgdTMy
IGFjaywKKwkJCQkgICAgdTMyIHNlcV9ydHQsIHUzMiBpbl9mbGlnaHQsIGludCBmbGFnKQorewor
CXN0cnVjdCB0Y3Bfc29jayAqdHAgPSB0Y3Bfc2soc2spOworCXN0cnVjdCBjb21wb3VuZCAqdmVn
YXMgPSBpbmV0X2Nza19jYShzayk7CisJdTggaW5jID0gMDsKKwkKKwl0Y3BfY29tcG91bmRfc3lu
Y2goc2spOworCiAJaWYgKCF0Y3BfaXNfY3duZF9saW1pdGVkKHNrLCBpbl9mbGlnaHQpKQogCQly
ZXR1cm47CiAKQEAgLTQxNSw5ICs0MjIsMjEgQEAKIAl9CiB9CiAKK3N0YXRpYyB1MzIgdGNwX2Nv
bXBvdW5kX3NzdGhyZXNoKHN0cnVjdCBzb2NrICpzaykgeworCXN0cnVjdCB0Y3Bfc29jayAqdHAg
PSB0Y3Bfc2soc2spOworCXN0cnVjdCBjb21wb3VuZCAqdmVnYXMgPSBpbmV0X2Nza19jYShzayk7
CisKKwl0Y3BfY29tcG91bmRfc3luY2goc2spOworCQorCXZlZ2FzLT5kd25kID0gMDsKKwl0cC0+
c25kX2N3bmQgPSB2ZWdhcy0+Y3duZDsKKwkKKwlyZXR1cm4gdGNwX3Jlbm9fc3N0aHJlc2goc2sp
OworfQorCiBzdGF0aWMgc3RydWN0IHRjcF9jb25nZXN0aW9uX29wcyB0Y3BfY29tcG91bmQgPSB7
CiAJLmluaXQJCT0gdGNwX2NvbXBvdW5kX2luaXQsCi0JLnNzdGhyZXNoCT0gdGNwX3Jlbm9fc3N0
aHJlc2gsCisJLnNzdGhyZXNoCT0gdGNwX2NvbXBvdW5kX3NzdGhyZXNoLAogCS5jb25nX2F2b2lk
CT0gdGNwX2NvbXBvdW5kX2NvbmdfYXZvaWQsCiAJLm1pbl9jd25kCT0gdGNwX3Jlbm9fbWluX2N3
bmQsCiAJLnJ0dF9zYW1wbGUJPSB0Y3BfY29tcG91bmRfcnR0X2NhbGMsCg==
------=_Part_175516_19355983.1152113351923--
