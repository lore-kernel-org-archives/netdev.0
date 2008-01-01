From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPV4] Remove three declarations of unimplemented methods and correct a typo in include/net/ip.h
Date: Tue, 1 Jan 2008 10:30:53 +0200
Message-ID: <eb3ff54b0801010030g36bef670n6150af5b683c4345@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5070_12417523.1199176253906"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:55521 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbYAAIa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jan 2008 03:30:57 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2858117fga.17
        for <netdev@vger.kernel.org>; Tue, 01 Jan 2008 00:30:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_5070_12417523.1199176253906
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
These three declarations in include/net/ip.h are not implemented
anywhere:
ip_mc_dropsocket(), ip_mc_dropdevice() and ip_net_unreachable().

Also, correct a comment to be "Functions provided by ip_fragment.c"
(instead of by ip_fragment.o) in consistency with the other comments in this
header.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_5070_12417523.1199176253906
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_faw6icro0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2lwLmggYi9pbmNsdWRlL25ldC9pcC5oCmluZGV4IDVm
YWIzYTEuLjhiZTQ4YzggMTAwNjQ0Ci0tLSBhL2luY2x1ZGUvbmV0L2lwLmgKKysrIGIvaW5jbHVk
ZS9uZXQvaXAuaApAQCAtODIsOCArODIsNiBAQCBzdHJ1Y3QgcGFja2V0X3R5cGU7CiBzdHJ1Y3Qg
cnRhYmxlOwogc3RydWN0IHNvY2thZGRyOwogCi1leHRlcm4gdm9pZAkJaXBfbWNfZHJvcHNvY2tl
dChzdHJ1Y3Qgc29jayAqKTsKLWV4dGVybiB2b2lkCQlpcF9tY19kcm9wZGV2aWNlKHN0cnVjdCBu
ZXRfZGV2aWNlICpkZXYpOwogZXh0ZXJuIGludAkJaWdtcF9tY19wcm9jX2luaXQodm9pZCk7CiAK
IC8qCkBAIC0zMTksNyArMzE3LDcgQEAgc3RhdGljIF9faW5saW5lX18gdm9pZCBpbmV0X3Jlc2V0
X3NhZGRyKHN0cnVjdCBzb2NrICpzaykKIGV4dGVybiBpbnQJaXBfY2FsbF9yYV9jaGFpbihzdHJ1
Y3Qgc2tfYnVmZiAqc2tiKTsKIAogLyoKLSAqCUZ1bmN0aW9ucyBwcm92aWRlZCBieSBpcF9mcmFn
bWVudC5vCisgKglGdW5jdGlvbnMgcHJvdmlkZWQgYnkgaXBfZnJhZ21lbnQuYwogICovCiAKIGVu
dW0gaXBfZGVmcmFnX3VzZXJzCkBAIC0zNDIsNyArMzQwLDYgQEAgaW50IGlwX2ZyYWdfbnF1ZXVl
cyh2b2lkKTsKICAqLwogIAogZXh0ZXJuIGludCBpcF9mb3J3YXJkKHN0cnVjdCBza19idWZmICpz
a2IpOwotZXh0ZXJuIGludCBpcF9uZXRfdW5yZWFjaGFibGUoc3RydWN0IHNrX2J1ZmYgKnNrYik7
CiAgCiAvKgogICoJRnVuY3Rpb25zIHByb3ZpZGVkIGJ5IGlwX29wdGlvbnMuYwo=
------=_Part_5070_12417523.1199176253906--
