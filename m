From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next-2.6 ] ipv4: remove ip_mc_drop_socket() declaration
	from af_inet.c.
Date: Wed, 3 Jun 2009 23:47:04 +0300
Message-ID: <eb3ff54b0906031347l13de166du58abb40d74e931b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=00151748de6c0d298c046b77c3a2
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f212.google.com ([209.85.219.212]:57253 "EHLO
	mail-ew0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754820AbZFCUyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 16:54:15 -0400
Received: by ewy8 with SMTP id 8so484559ewy.40
        for <netdev@vger.kernel.org>; Wed, 03 Jun 2009 13:54:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--00151748de6c0d298c046b77c3a2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi,

ip_mc_drop_socket() method is declared in linux/igmp.h, which
is included anyhow in af_inet.c. So there is no need for this declaration.
This patch removes it from af_inet.c.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

--00151748de6c0d298c046b77c3a2
Content-Type: text/plain; charset=US-ASCII; name="patch.txt"
Content-Disposition: attachment; filename="patch.txt"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fvii9yiu0

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L2FmX2luZXQuYyBiL25ldC9pcHY0L2FmX2luZXQuYwppbmRl
eCBkODczNjIxLi41NjZlYTZjIDEwMDY0NAotLS0gYS9uZXQvaXB2NC9hZl9pbmV0LmMKKysrIGIv
bmV0L2lwdjQvYWZfaW5ldC5jCkBAIC0xMTYsNyArMTE2LDYgQEAKICNpbmNsdWRlIDxsaW51eC9t
cm91dGUuaD4KICNlbmRpZgogCi1leHRlcm4gdm9pZCBpcF9tY19kcm9wX3NvY2tldChzdHJ1Y3Qg
c29jayAqc2spOwogCiAvKiBUaGUgaW5ldHN3IHRhYmxlIGNvbnRhaW5zIGV2ZXJ5dGhpbmcgdGhh
dCBpbmV0X2NyZWF0ZSBuZWVkcyB0bwogICogYnVpbGQgYSBuZXcgc29ja2V0Lgo=
--00151748de6c0d298c046b77c3a2--
