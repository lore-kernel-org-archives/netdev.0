From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [XFRM] Remove unneeded export of xfrm_output_resume() and remove its declaration from net/xfrm.h.
Date: Sat, 19 Jan 2008 15:13:53 +0200
Message-ID: <eb3ff54b0801190513k6b59ce6cq956ac8ebb6dc5e40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4157_12280895.1200748433871"
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:57269 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751898AbYASNN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jan 2008 08:13:57 -0500
Received: by fg-out-1718.google.com with SMTP id e21so1318716fga.17
        for <netdev@vger.kernel.org>; Sat, 19 Jan 2008 05:13:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_4157_12280895.1200748433871
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

The method xfrm_output_resume() is used only in net/xfrm/xfrm_output.c.

This patch removes using unneeded EXPORT_SYMBOL_GPL to export it in
net/xfrm/xfrm_output.c and also removes its declaration in net/xfrm.h.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_4157_12280895.1200748433871
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fbm6hsut0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L3hmcm0uaCBiL2luY2x1ZGUvbmV0L3hmcm0uaAppbmRl
eCA1ZWJiOWJhLi40MGFlMTMzIDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC94ZnJtLmgKKysrIGIv
aW5jbHVkZS9uZXQveGZybS5oCkBAIC0xMjQyLDcgKzEyNDIsNiBAQCBleHRlcm4gaW50IHhmcm1f
cHJlcGFyZV9pbnB1dChzdHJ1Y3QgeGZybV9zdGF0ZSAqeCwgc3RydWN0IHNrX2J1ZmYgKnNrYik7
CiBleHRlcm4gaW50IHhmcm1faW5wdXQoc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW50IG5leHRoZHIs
IF9fYmUzMiBzcGksCiAJCSAgICAgIGludCBlbmNhcF90eXBlKTsKIGV4dGVybiBpbnQgeGZybV9p
bnB1dF9yZXN1bWUoc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW50IG5leHRoZHIpOwotZXh0ZXJuIGlu
dCB4ZnJtX291dHB1dF9yZXN1bWUoc3RydWN0IHNrX2J1ZmYgKnNrYiwgaW50IGVycik7CiBleHRl
cm4gaW50IHhmcm1fb3V0cHV0KHN0cnVjdCBza19idWZmICpza2IpOwogZXh0ZXJuIGludCB4ZnJt
NF9leHRyYWN0X2hlYWRlcihzdHJ1Y3Qgc2tfYnVmZiAqc2tiKTsKIGV4dGVybiBpbnQgeGZybTRf
ZXh0cmFjdF9pbnB1dChzdHJ1Y3QgeGZybV9zdGF0ZSAqeCwgc3RydWN0IHNrX2J1ZmYgKnNrYik7
CmRpZmYgLS1naXQgYS9uZXQveGZybS94ZnJtX291dHB1dC5jIGIvbmV0L3hmcm0veGZybV9vdXRw
dXQuYwppbmRleCBmNGExMDQ3Li45YTZlOTJlIDEwMDY0NAotLS0gYS9uZXQveGZybS94ZnJtX291
dHB1dC5jCisrKyBiL25ldC94ZnJtL3hmcm1fb3V0cHV0LmMKQEAgLTEzNiw3ICsxMzYsNiBAQCBp
bnQgeGZybV9vdXRwdXRfcmVzdW1lKHN0cnVjdCBza19idWZmICpza2IsIGludCBlcnIpCiBvdXQ6
CiAJcmV0dXJuIGVycjsKIH0KLUVYUE9SVF9TWU1CT0xfR1BMKHhmcm1fb3V0cHV0X3Jlc3VtZSk7
CiAKIHN0YXRpYyBpbnQgeGZybV9vdXRwdXQyKHN0cnVjdCBza19idWZmICpza2IpCiB7Cg==
------=_Part_4157_12280895.1200748433871--
