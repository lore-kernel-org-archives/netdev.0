From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] ip: update the description of rp_filter in ip-sysctl.txt
Date: Tue, 01 Dec 2009 15:04:32 +0800
Message-ID: <4B14C000.3090608@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	rdunlap@xenotime.net
To: David Miller <davem@davemloft.net>, shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50571 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750937AbZLAHFa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 02:05:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 27fed4175acf81ddd91d9a4ee2fd298981f60295
=EF=BC=88ip: fix logic of reverse path filter sysctl=EF=BC=89has change=
d the logic of rp_filter.
The document about rp_filter is out of date. Now, setting conf/all/rp_f=
ilte with 0=20
can also enable source validation. =20

Update the document according to the commit.

Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 Documentation/networking/ip-sysctl.txt |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/net=
working/ip-sysctl.txt
index fbe427a..5dcc067 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -738,8 +738,8 @@ rp_filter - INTEGER
 	to prevent IP spoofing from DDos attacks. If using asymmetric routing
 	or other complicated routing, then loose mode is recommended.
=20
-	conf/all/rp_filter must also be set to non-zero to do source validati=
on
-	on the interface
+	The max value from conf/{all,interface}/rp_filter is used
+	when doing source validation on the {interface}.
=20
 	Default value is 0. Note that some distributions enable it
 	in startup scripts.
--=20
1.6.3.3

