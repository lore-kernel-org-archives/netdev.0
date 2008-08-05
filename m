From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6] ipv4: remove unused field in struct flowi (include/net/flow.h).
Date: Tue, 5 Aug 2008 11:14:02 +0300
Message-ID: <eb3ff54b0808050114xf95cca1kab4971f6f9bd4103@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1945_32785748.1217924042039"
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:12993 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754693AbYHEIOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 04:14:02 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3833370wfd.4
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 01:14:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_1945_32785748.1217924042039
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch removes an unused field (flags) from struct flowi;
it seems that this "flags" field was used once in the past for
multipath routing with
FLOWI_FLAG_MULTIPATHOLDROUTE flag  (which does no longer exist);
however, the "flags"
field of struct flowi is not used anymore.


Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_1945_32785748.1217924042039
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fji8dcu30
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2Zsb3cuaCBiL2luY2x1ZGUvbmV0L2Zsb3cuaAppbmRl
eCBhZDE2ZTAwLi4yMjhiMjQ3IDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9mbG93LmgKKysrIGIv
aW5jbHVkZS9uZXQvZmxvdy5oCkBAIC00Nyw3ICs0Nyw2IEBAIHN0cnVjdCBmbG93aSB7CiAjZGVm
aW5lIGZsNF9zY29wZQlubF91LmlwNF91LnNjb3BlCiAKIAlfX3U4CXByb3RvOwotCV9fdTgJZmxh
Z3M7CiAJdW5pb24gewogCQlzdHJ1Y3QgewogCQkJX19iZTE2CXNwb3J0Owo=
------=_Part_1945_32785748.1217924042039--
