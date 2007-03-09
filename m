From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Subject: [PATCH 1/1][UDP]: Use __skb_pull since we have checked it won't fail with pskb_may_pull
Date: Fri, 9 Mar 2007 11:07:50 -0300
Message-ID: <39e6f6c70703090607h29e1a0d0lef770fdc02b16eab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2965_25732734.1173449270891"
Cc: "Netdev List" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:33374 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767303AbXCIOH4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 09:07:56 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1335552uga
        for <netdev@vger.kernel.org>; Fri, 09 Mar 2007 06:07:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------=_Part_2965_25732734.1173449270891
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

---
 net/ipv4/udp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

------=_Part_2965_25732734.1173449270891
Content-Type: text/x-patch; name=udp__skb_pull.patch; charset=ANSI_X3.4-1968
Content-Transfer-Encoding: base64
X-Attachment-Id: f_ez2pdjb7
Content-Disposition: attachment; filename="udp__skb_pull.patch"

ZGlmZiAtLWdpdCBhL25ldC9pcHY0L3VkcC5jIGIvbmV0L2lwdjQvdWRwLmMKaW5kZXggY2EzNTM4
MC4uMWJiZjU1MSAxMDA2NDQKLS0tIGEvbmV0L2lwdjQvdWRwLmMKKysrIGIvbmV0L2lwdjQvdWRw
LmMKQEAgLTEwMDIsNyArMTAwMiw3IEBAIHN0YXRpYyBpbnQgdWRwX2VuY2FwX3JjdihzdHJ1Y3Qg
c29jayAqIHNrLCBzdHJ1Y3Qgc2tfYnVmZiAqc2tiKQogCSAqIHRyYW5zcG9ydCBoZWFkZXIgdG8g
cG9pbnQgdG8gRVNQLiAgS2VlcCBVRFAgb24gdGhlIHN0YWNrCiAJICogZm9yIGxhdGVyLgogCSAq
LwotCXNrYi0+aC5yYXcgPSBza2JfcHVsbChza2IsIGxlbik7CisJc2tiLT5oLnJhdyA9IF9fc2ti
X3B1bGwoc2tiLCBsZW4pOwogCiAJLyogbW9kaWZ5IHRoZSBwcm90b2NvbCAoaXQncyBFU1AhKSAq
LwogCWlwaC0+cHJvdG9jb2wgPSBJUFBST1RPX0VTUDsK
------=_Part_2965_25732734.1173449270891--
