From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6] xfrm: remove unneeded method typedef declaration
 in net/xfrm.h.
Date: Fri, 24 Feb 2012 14:17:24 +0200
Message-ID: <CAHLOa7SLiHakXirjV2Q2tnC0u-zZuZp1s8sk+y3iZXevGw0ZDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=e89a8ff1c30a4e6d7b04b9b4be1a
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:36301 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751704Ab2BXMRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2012 07:17:25 -0500
Received: by daed14 with SMTP id d14so2435883dae.19
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2012 04:17:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--e89a8ff1c30a4e6d7b04b9b4be1a
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi,

=A0The patch removes unneeded method typedef declaration
(icv_update_fn_t ) in net/xfrm.h.
(I am sending the same patch again as my former mail was  rejected by
the vger server, now I believe it will be fine).

icv_update_fn_t was used in the past, for example in xfrm_algo.c (as a
parameter to skb_icv_walk() method), but it is no longer used
anywhere.

This patch removes it and the two struct declarations which appear in
its prototype

=A0(struct hash_desc and struct scatterlist)


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--e89a8ff1c30a4e6d7b04b9b4be1a
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gz16lavg0

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3hmcm0uaCBiL2luY2x1ZGUvbmV0L3hmcm0uaAppbmRl
eCA4OTE3NGUyLi45NjIzOWU3IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC94ZnJtLmgKKysrIGIv
aW5jbHVkZS9uZXQveGZybS5oCkBAIC0xNTY2LDExICsxNTY2LDYgQEAgZXh0ZXJuIHN0cnVjdCB4
ZnJtX2FsZ29fZGVzYyAqeGZybV9jYWxnX2dldF9ieW5hbWUoY29uc3QgY2hhciAqbmFtZSwgaW50
IHByb2JlKTsKIGV4dGVybiBzdHJ1Y3QgeGZybV9hbGdvX2Rlc2MgKnhmcm1fYWVhZF9nZXRfYnlu
YW1lKGNvbnN0IGNoYXIgKm5hbWUsIGludCBpY3ZfbGVuLAogCQkJCQkJICAgaW50IHByb2JlKTsK
IAotc3RydWN0IGhhc2hfZGVzYzsKLXN0cnVjdCBzY2F0dGVybGlzdDsKLXR5cGVkZWYgaW50IChp
Y3ZfdXBkYXRlX2ZuX3QpKHN0cnVjdCBoYXNoX2Rlc2MgKiwgc3RydWN0IHNjYXR0ZXJsaXN0ICos
Ci0JCQkgICAgICB1bnNpZ25lZCBpbnQpOwotCiBzdGF0aWMgaW5saW5lIGludCB4ZnJtX2FkZHJf
Y21wKGNvbnN0IHhmcm1fYWRkcmVzc190ICphLAogCQkJCWNvbnN0IHhmcm1fYWRkcmVzc190ICpi
LAogCQkJCWludCBmYW1pbHkpCg==
--e89a8ff1c30a4e6d7b04b9b4be1a--
