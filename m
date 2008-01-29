From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6.25] [MACVLAN] Setting macvlan_handle_frame_hook to NULL when rtnl_link_register() fails.
Date: Tue, 29 Jan 2008 17:14:50 +0200
Message-ID: <eb3ff54b0801290714ja7e7e67t3349028b7db8dc5e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_4589_3649271.1201619690374"
To: kaber@trash.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.153]:38823 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782AbYA2POv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 10:14:51 -0500
Received: by fg-out-1718.google.com with SMTP id e21so2114907fga.17
        for <netdev@vger.kernel.org>; Tue, 29 Jan 2008 07:14:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_4589_3649271.1201619690374
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi,
  In drivers/net/macvlan.c, when rtnl_link_register() fails
in macvlan_init_module(), there is no point to set it (second time in this
method) to macvlan_handle_frame; macvlan_init_module() will return a negative
number, so instead this patch sets macvlan_handle_frame_hook to NULL.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>

------=_Part_4589_3649271.1201619690374
Content-Type: text/plain; name=patch.txt
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fc0la4h10
Content-Disposition: attachment; filename=patch.txt

ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L21hY3ZsYW4uYyBiL2RyaXZlcnMvbmV0L21hY3ZsYW4u
YwppbmRleCA2ZWY2YjhiLi5mNjUxYTgxIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9tYWN2bGFu
LmMKKysrIGIvZHJpdmVycy9uZXQvbWFjdmxhbi5jCkBAIC01MDgsNyArNTA4LDcgQEAgc3RhdGlj
IGludCBfX2luaXQgbWFjdmxhbl9pbml0X21vZHVsZSh2b2lkKQogCQlnb3RvIGVycjE7CiAJcmV0
dXJuIDA7CiBlcnIxOgotCW1hY3ZsYW5faGFuZGxlX2ZyYW1lX2hvb2sgPSBtYWN2bGFuX2hhbmRs
ZV9mcmFtZTsKKwltYWN2bGFuX2hhbmRsZV9mcmFtZV9ob29rID0gTlVMTDsKIAl1bnJlZ2lzdGVy
X25ldGRldmljZV9ub3RpZmllcigmbWFjdmxhbl9ub3RpZmllcl9ibG9jayk7CiAJcmV0dXJuIGVy
cjsKIH0K
------=_Part_4589_3649271.1201619690374--
