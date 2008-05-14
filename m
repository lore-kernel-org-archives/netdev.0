From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.26] Fix typo in net/core/sock.c.
Date: Wed, 14 May 2008 12:27:47 +0300
Message-ID: <eb3ff54b0805140227h48fc5460hf00b1ff6eb080baa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_461_18251622.1210757267286"
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:33955 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754124AbYENJ1t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 05:27:49 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2470777fgg.17
        for <netdev@vger.kernel.org>; Wed, 14 May 2008 02:27:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_461_18251622.1210757267286
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

In sock_queue_rcv_skb()  (net/core/sock.c) it should be:
"Cast sk->rcvbuf ..." instead of: "Cast skb->rcvbuf ..."


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_461_18251622.1210757267286
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fg7pj4ab0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9jb3JlL3NvY2suYyBiL25ldC9jb3JlL3NvY2suYwppbmRleCBmYTc2
ZjA0Li44ODA5NGNiIDEwMDY0NAotLS0gYS9uZXQvY29yZS9zb2NrLmMKKysrIGIvbmV0L2NvcmUv
c29jay5jCkBAIC0yNzAsNyArMjcwLDcgQEAgaW50IHNvY2tfcXVldWVfcmN2X3NrYihzdHJ1Y3Qg
c29jayAqc2ssIHN0cnVjdCBza19idWZmICpza2IpCiAJaW50IGVyciA9IDA7CiAJaW50IHNrYl9s
ZW47CiAKLQkvKiBDYXN0IHNrYi0+cmN2YnVmIHRvIHVuc2lnbmVkLi4uIEl0J3MgcG9pbnRsZXNz
LCBidXQgcmVkdWNlcworCS8qIENhc3Qgc2stPnJjdmJ1ZiB0byB1bnNpZ25lZC4uLiBJdCdzIHBv
aW50bGVzcywgYnV0IHJlZHVjZXMKIAkgICBudW1iZXIgb2Ygd2FybmluZ3Mgd2hlbiBjb21waWxp
bmcgd2l0aCAtVyAtLUFOSwogCSAqLwogCWlmIChhdG9taWNfcmVhZCgmc2stPnNrX3JtZW1fYWxs
b2MpICsgc2tiLT50cnVlc2l6ZSA+PQo=
------=_Part_461_18251622.1210757267286--
