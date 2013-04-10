From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] netprio_cgroup: make local table static
Date: Wed, 10 Apr 2013 13:56:05 -0700
Message-ID: <20130410135605.0431e7aa@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f41.google.com ([209.85.210.41]:57819 "EHLO
	mail-da0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab3DJU40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 16:56:26 -0400
Received: by mail-da0-f41.google.com with SMTP id w4so377006dam.28
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 13:56:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor sparse warning

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/net/core/netprio_cgroup.c	2013-04-10 13:36:56.928429191 -0700
+++ b/net/core/netprio_cgroup.c	2013-04-10 13:37:04.516330753 -0700
@@ -247,7 +247,7 @@ static struct cftype ss_files[] = {
 	{ }	/* terminate */
 };
 
-struct cgroup_subsys net_prio_subsys = {
+static struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.css_alloc	= cgrp_css_alloc,
 	.css_online	= cgrp_css_online,
