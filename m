From: "Manish Katiyar" <mkatiyar@gmail.com>
Subject: [PATCH] : Fix unused variable compilation warnings in drivers/net/wan/syncppp.c
Date: Mon, 27 Oct 2008 18:20:42 +0530
Message-ID: <ea11fea30810270550g3626456eh84f5c9ed6d79d847@mail.gmail.com>
References: <ea11fea30810270548y11453b8i10eb53caff1838e8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:38213 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751541AbYJ0Mun (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 08:50:43 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1157506tic.23
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2008 05:50:42 -0700 (PDT)
In-Reply-To: <ea11fea30810270548y11453b8i10eb53caff1838e8@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[resending it to netdev].


---------- Forwarded message ----------
From: Manish Katiyar <mkatiyar@gmail.com>
Date: Mon, Oct 27, 2008 at 6:18 PM
Subject: [PATCH] : Fix unused variable compilation warnings in
drivers/net/wan/syncppp.c
To: kernel-janitors@vger.kernel.org, linux-netdev@vger.kernel.org,
LKML <linux-kernel@vger.kernel.org>
Cc: mkatiyar@gmail.com


Below patch fixes the unused compilation warnings in
drivers/net/wan/syncppp.c when CONFIG_INET is not defined.

Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
---
 drivers/net/wan/syncppp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/syncppp.c b/drivers/net/wan/syncppp.c
index 327d585..11124f3 100644
--- a/drivers/net/wan/syncppp.c
+++ b/drivers/net/wan/syncppp.c
@@ -756,10 +756,10 @@ static void sppp_cisco_input (struct sppp *sp,
struct sk_buff *skb)
       case CISCO_ADDR_REQ:
               /* Stolen from net/ipv4/devinet.c -- SIOCGIFADDR ioctl */
               {
-               struct in_device *in_dev;
-               struct in_ifaddr *ifa;
               __be32 addr = 0, mask = htonl(~0U); /* FIXME: is the
mask correct? */
 #ifdef CONFIG_INET
+               struct in_device *in_dev;
+               struct in_ifaddr *ifa;
               rcu_read_lock();
               if ((in_dev = __in_dev_get_rcu(dev)) != NULL)
               {
--
1.5.4.3


Thanks -
Manish
