From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Thu, 12 Nov 2009 17:48:05 +0800
Message-ID: <412e6f7f0911120148r48fa553bt610e013d96522a3d@mail.gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=001636e0a6c09b801c0478297036
Cc: xiaosuo@gmail.com, Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:44615 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752039AbZKLJr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 04:47:59 -0500
Received: by pzk1 with SMTP id 1so421988pzk.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 01:48:05 -0800 (PST)
In-Reply-To: <4AFBD911.6000900@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--001636e0a6c09b801c0478297036
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: quoted-printable

The corresponding iprout2 patch is attached.

--=20
Regards=A3=AC
Changli Gao(xiaosuo@gmail.com)

--001636e0a6c09b801c0478297036
Content-Type: application/octet-stream; name="iproute2-support-numtxqs.diff"
Content-Disposition: attachment; filename="iproute2-support-numtxqs.diff"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g1xc6slg0

LS0tIGlwL2lwbGluay5jLm9yaWcJMjAwOS0xMS0xMSAxNjo1Njo0MS4wMDAwMDAwMDAgKzA4MDAK
KysrIGlwL2lwbGluay5jCTIwMDktMTEtMTIgMTQ6NTc6MjUuMDAwMDAwMDAwICswODAwCkBAIC00
OCw2ICs0OCw3IEBACiAJCWZwcmludGYoc3RkZXJyLCAiICAgICAgICAgICAgICAgICAgIFsgYWRk
cmVzcyBMTEFERFIgXVxuIik7CiAJCWZwcmludGYoc3RkZXJyLCAiICAgICAgICAgICAgICAgICAg
IFsgYnJvYWRjYXN0IExMQUREUiBdXG4iKTsKIAkJZnByaW50ZihzdGRlcnIsICIgICAgICAgICAg
ICAgICAgICAgWyBtdHUgTVRVIF1cbiIpOworCQlmcHJpbnRmKHN0ZGVyciwgIiAgICAgICAgICAg
ICAgICAgICBbIG51bXR4cXMgTlVNVFhRUyBdXG4iKTsKIAkJZnByaW50ZihzdGRlcnIsICIgICAg
ICAgICAgICAgICAgICAgdHlwZSBUWVBFIFsgQVJHUyBdXG4iKTsKIAkJZnByaW50ZihzdGRlcnIs
ICIgICAgICAgaXAgbGluayBkZWxldGUgREVWIHR5cGUgVFlQRSBbIEFSR1MgXVxuIik7CiAJCWZw
cmludGYoc3RkZXJyLCAiXG4iKTsKQEAgLTE4MCw2ICsxODEsNyBAQAogCWludCBxbGVuID0gLTE7
CiAJaW50IG10dSA9IC0xOwogCWludCBuZXRucyA9IC0xOworCWludCBudW10eHFzID0gLTE7CiAK
IAlyZXQgPSBhcmdjOwogCkBAIC0yMjEsNiArMjIzLDEzIEBACiAJCQlpZiAoZ2V0X2ludGVnZXIo
Jm10dSwgKmFyZ3YsIDApKQogCQkJCWludmFyZygiSW52YWxpZCBcIm10dVwiIHZhbHVlXG4iLCAq
YXJndik7CiAJCQlhZGRhdHRyX2woJnJlcS0+biwgc2l6ZW9mKCpyZXEpLCBJRkxBX01UVSwgJm10
dSwgNCk7CisJCX0gZWxzZSBpZiAoc3RyY21wKCphcmd2LCAibnVtdHhxcyIpID09IDApIHsKKwkJ
CU5FWFRfQVJHKCk7CisJCQlpZiAobnVtdHhxcyAhPSAtMSkKKwkJCQlkdXBhcmcoIm51bXR4cXMi
LCAqYXJndik7CisJCQlpZiAoZ2V0X2ludGVnZXIoJm51bXR4cXMsICphcmd2LCAwKSkKKwkJCQlp
bnZhcmcoIkludmFsaWQgXCJudW10eHFzXCIgdmFsdWVcbiIsICphcmd2KTsKKwkJCWFkZGF0dHJf
bCgmcmVxLT5uLCBzaXplb2YoKnJlcSksIElGTEFfTlRYUSwgJm51bXR4cXMsIDQpOwogICAgICAg
ICAgICAgICAgIH0gZWxzZSBpZiAoc3RyY21wKCphcmd2LCAibmV0bnMiKSA9PSAwKSB7CiAgICAg
ICAgICAgICAgICAgICAgICAgICBORVhUX0FSRygpOwogICAgICAgICAgICAgICAgICAgICAgICAg
aWYgKG5ldG5zICE9IC0xKQo=
--001636e0a6c09b801c0478297036--
