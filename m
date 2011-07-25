From: Bin Li <libin.charles@gmail.com>
Subject: [PATCH] Fix little error for the man page of 'ip link'
Date: Mon, 25 Jul 2011 14:34:47 +0800
Message-ID: <CAGBH1r6jrfmgaVyio1do237ns81_JjwQh88_Jbvt9q0zXEFC4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0003255765f6fccee604a8df0269
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:35168 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab1GYGes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2011 02:34:48 -0400
Received: by iyb12 with SMTP id 12so4291394iyb.19
        for <netdev@vger.kernel.org>; Sun, 24 Jul 2011 23:34:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0003255765f6fccee604a8df0269
Content-Type: text/plain; charset=ISO-8859-1

Hi,

The original patch could found here.

http://git.kernel.org/?p=linux/kernel/git/shemminger/iproute2.git;a=commitdiff;h=df33d7a489e13b69caa8b55064e01e99bdabef15

And the below trunk shouldn't be delete. The correct should be "ip
link set DEVICE { .. | .. | ..}" instead of "ip link set DEVICE { .. |
.. | .."

-------------------------------------------------------------------
@@ -68,8 +96,6 @@ ip \- show / manipulate routing, devices, policy
routing and tunnels
 .IR VLAN-QOS " ] ] ["
 .B rate
 .IR TXRATE " ]"
-.BR " }"
-

 .ti -8
 .B ip link show
-------------------------------------------------------------------

Please my patch in the attachment or below. Just add it back. Thanks!

-------------------------------------------------------------------
Index: iproute2/man/man8/ip.8
===================================================================
--- iproute2.orig/man/man8/ip.8
+++ iproute2/man/man8/ip.8
@@ -106,6 +106,8 @@ ip \- show / manipulate routing, devices
 .IR DEVICE
 .br
 .B nomaster
+.BR " }"
+

 .ti -8
 .B ip link show
-------------------------------------------------------------------

Sincerely Yours,

Bin Li

http://zh.opensuse.org

--0003255765f6fccee604a8df0269
Content-Type: text/x-patch; charset=US-ASCII; name="ip_link_set_man.patch"
Content-Disposition: attachment; filename="ip_link_set_man.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gqj238mv0

SW5kZXg6IGlwcm91dGUyL21hbi9tYW44L2lwLjgKPT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQotLS0gaXByb3V0ZTIub3Jp
Zy9tYW4vbWFuOC9pcC44CisrKyBpcHJvdXRlMi9tYW4vbWFuOC9pcC44CkBAIC0xMDYsNiArMTA2
LDggQEAgaXAgXC0gc2hvdyAvIG1hbmlwdWxhdGUgcm91dGluZywgZGV2aWNlcwogLklSIERFVklD
RQogLmJyCiAuQiBub21hc3RlcgorLkJSICIgfSIKKwogCiAudGkgLTgKIC5CIGlwIGxpbmsgc2hv
dwo=
--0003255765f6fccee604a8df0269--
