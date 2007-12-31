From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [IPV4] Remove unused multipath cached routing defintion in net/flow.h
Date: Mon, 31 Dec 2007 13:15:19 +0200
Message-ID: <eb3ff54b0712310315l4df16c6fye0bf2a82505d20be@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4782_10435617.1199099719565"
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:4390 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280AbXLaLPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 06:15:21 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2631536fga.17
        for <netdev@vger.kernel.org>; Mon, 31 Dec 2007 03:15:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_4782_10435617.1199099719565
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,

The FLOWI_FLAG_MULTIPATHOLDROUTE definition in include/net/flow.h is an unused
  definition. It belongs to IPV4 multipath cached routing support,
   which has been dropped recently for 2.6.23 kernel (July 2007).
	
Regards,
Rami Rosen

http://www.linux-foundation.org/en/Net:Network_Overview


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_4782_10435617.1199099719565
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fauvw74v0
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbmV0L2Zsb3cuaCBiL2luY2x1ZGUvbmV0L2Zsb3cuaAppbmRl
eCBhZjU5ZmE1Li5hZDE2ZTAwIDEwMDY0NAotLS0gYS9pbmNsdWRlL25ldC9mbG93LmgKKysrIGIv
aW5jbHVkZS9uZXQvZmxvdy5oCkBAIC00OCw3ICs0OCw2IEBAIHN0cnVjdCBmbG93aSB7CiAKIAlf
X3U4CXByb3RvOwogCV9fdTgJZmxhZ3M7Ci0jZGVmaW5lIEZMT1dJX0ZMQUdfTVVMVElQQVRIT0xE
Uk9VVEUgMHgwMQogCXVuaW9uIHsKIAkJc3RydWN0IHsKIAkJCV9fYmUxNglzcG9ydDsK
------=_Part_4782_10435617.1199099719565--
