From: Gabriel C <nix.or.die@googlemail.com>
Subject: [PATCH] NET_CLS_RSVP6 should depend on IPV6
Date: Sat, 14 Jul 2007 12:38:46 +0200
Message-ID: <4698A7B6.1030302@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, netdev@vger.kernel.org
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:12627 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754558AbXGNKjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jul 2007 06:39:14 -0400
Received: by nf-out-0910.google.com with SMTP id g13so51687nfb
        for <netdev@vger.kernel.org>; Sat, 14 Jul 2007 03:39:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

cls_rsvp6 only works with IPV6 enabled kernels and IMO it should depends
on IPV6.


Signed-off-by: Gabriel Craciunescu <nix.or.die@googlemail.com>

---

net/sched/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index b466288..200976e 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -299,6 +299,7 @@ config NET_CLS_RSVP
 
 config NET_CLS_RSVP6
        tristate "IPv6 Resource Reservation Protocol (RSVP6)"
+       depends on IPV6
        select NET_CLS
        ---help---
          The Resource Reservation Protocol (RSVP) permits end systems to
@@ -306,7 +307,7 @@ config NET_CLS_RSVP6
          is important for real time data such as streaming sound or video.
 
          Say Y here if you want to be able to classify outgoing packets
based
-         on their RSVP requests and you are using the IPv6.
+         on their RSVP requests and you are using the IPv6 protocol.
 
          To compile this code as a module, choose M here: the
          module will be called cls_rsvp6.


