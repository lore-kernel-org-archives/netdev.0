From: "Rami Rosen" <ramirose@gmail.com>
Subject: Re: [PATCH net-2.6 2/2] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c (RESEND).
Date: Tue, 17 Jun 2008 09:22:53 +0300
Message-ID: <eb3ff54b0806162322n3952164cm7ab9f1749a52b2de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_41782_19105315.1213683773196"
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:1037 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbYFQGW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 02:22:56 -0400
Received: by rv-out-0506.google.com with SMTP id k40so4044459rvb.1
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 23:22:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_41782_19105315.1213683773196
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In net/ipv6/tcp_ipv6.c:

1) Remove unneeded tcp_v6_send_check() declaration.

2) Unify two consecutive #ifdef CONFIG_TCP_MD5SIG (with nothing in
  between them) into one #ifdef CONFIG_TCP_MD5SIG.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>
On Tue, Jun 17, 2008 at 3:08 AM, David Miller <davem@davemloft.net> wrote:
> From: "Rami Rosen" <ramirose@gmail.com>
> Date: Mon, 16 Jun 2008 12:09:31 +0300
>
>> 2) Unify two consecutive #ifdef CONFIG_TCP_MD5SIG (with nothing in
>>    between them) into one #ifdef CONFIG_TCP_MD5SIG.
>
> I think there should be an empty line between local variable
> declarations and actual code in a function.  Please fix this
> up, thanks.
>
>

------=_Part_41782_19105315.1213683773196
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fhk3xj250
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9pcHY2L3RjcF9pcHY2LmMgYi9uZXQvaXB2Ni90Y3BfaXB2Ni5jCmlu
ZGV4IGNiNDY3NDkuLjQ4OGY5ZDggMTAwNjQ0Ci0tLSBhL25ldC9pcHY2L3RjcF9pcHY2LmMKKysr
IGIvbmV0L2lwdjYvdGNwX2lwdjYuYwpAQCAtNzIsOCArNzIsNiBAQAogCiBzdGF0aWMgdm9pZAl0
Y3BfdjZfc2VuZF9yZXNldChzdHJ1Y3Qgc29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpOwog
c3RhdGljIHZvaWQJdGNwX3Y2X3JlcXNrX3NlbmRfYWNrKHN0cnVjdCBza19idWZmICpza2IsIHN0
cnVjdCByZXF1ZXN0X3NvY2sgKnJlcSk7Ci1zdGF0aWMgdm9pZAl0Y3BfdjZfc2VuZF9jaGVjayhz
dHJ1Y3Qgc29jayAqc2ssIGludCBsZW4sCi0JCQkJICBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsKIAog
c3RhdGljIGludAl0Y3BfdjZfZG9fcmN2KHN0cnVjdCBzb2NrICpzaywgc3RydWN0IHNrX2J1ZmYg
KnNrYik7CiAKQEAgLTExMDEsOSArMTA5OSw3IEBAIHN0YXRpYyB2b2lkIHRjcF92Nl9zZW5kX2Fj
ayhzdHJ1Y3QgdGNwX3RpbWV3YWl0X3NvY2sgKnR3LAogI2lmZGVmIENPTkZJR19UQ1BfTUQ1U0lH
CiAJc3RydWN0IHRjcF9tZDVzaWdfa2V5ICprZXk7CiAJc3RydWN0IHRjcF9tZDVzaWdfa2V5IHR3
X2tleTsKLSNlbmRpZgogCi0jaWZkZWYgQ09ORklHX1RDUF9NRDVTSUcKIAlpZiAoIXR3ICYmIHNr
Yi0+c2spIHsKIAkJa2V5ID0gdGNwX3Y2X21kNV9kb19sb29rdXAoc2tiLT5zaywgJmlwdjZfaGRy
KHNrYiktPmRhZGRyKTsKIAl9IGVsc2UgaWYgKHR3ICYmIHR3LT50d19tZDVfa2V5bGVuKSB7Cg==

------=_Part_41782_19105315.1213683773196--
