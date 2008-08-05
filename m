From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6] bridge: fix compile warning in net/bridge/br_netfilter.c
Date: Tue, 5 Aug 2008 09:45:00 +0300
Message-ID: <eb3ff54b0808042345j256d28aapbadc22a1ad994ca9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1570_20639054.1217918700249"
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.172]:63020 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752786AbYHEGpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 02:45:00 -0400
Received: by wf-out-1314.google.com with SMTP id 27so3781331wfd.4
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2008 23:45:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_1570_20639054.1217918700249
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
This patch fixes the following warning due to incompatible pointer assignment:

net/bridge/br_netfilter.c: In function 'br_netfilter_rtable_init':
net/bridge/br_netfilter.c:116: warning: assignment from incompatible
pointer type

This warning is due to commit 4adf0af6818f3ea52421dc0bae836cfaf20ef72a
from  July 30
(send correct MTU value in PMTU (revised)).



Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_1570_20639054.1217918700249
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fji5b7wn0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL25ldC9icmlkZ2UvYnJfbmV0ZmlsdGVyLmMgYi9uZXQvYnJpZGdlL2JyX25l
dGZpbHRlci5jCmluZGV4IDZlMjgwYTguLjZhOWE2Y2QgMTAwNjQ0Ci0tLSBhL25ldC9icmlkZ2Uv
YnJfbmV0ZmlsdGVyLmMKKysrIGIvbmV0L2JyaWRnZS9icl9uZXRmaWx0ZXIuYwpAQCAtMTEzLDcg
KzExMyw3IEBAIHZvaWQgYnJfbmV0ZmlsdGVyX3J0YWJsZV9pbml0KHN0cnVjdCBuZXRfYnJpZGdl
ICpicikKIAlzdHJ1Y3QgcnRhYmxlICpydCA9ICZici0+ZmFrZV9ydGFibGU7CiAKIAlhdG9taWNf
c2V0KCZydC0+dS5kc3QuX19yZWZjbnQsIDEpOwotCXJ0LT51LmRzdC5kZXYgPSAmYnItPmRldjsK
KwlydC0+dS5kc3QuZGV2ID0gYnItPmRldjsKIAlydC0+dS5kc3QucGF0aCA9ICZydC0+dS5kc3Q7
CiAJcnQtPnUuZHN0Lm1ldHJpY3NbUlRBWF9NVFUgLSAxXSA9IDE1MDA7CiAJcnQtPnUuZHN0LmZs
YWdzCT0gRFNUX05PWEZSTTsK
------=_Part_1570_20639054.1217918700249--
