From: Jiri Pirko <jiri@resnulli.us>
Subject: value of dev->addr_assign_type
Date: Mon, 24 Dec 2012 10:47:30 +0100
Message-ID: <20121224094730.GB1559@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sassmann@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:40828 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab2LXJrg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 04:47:36 -0500
Received: by mail-ee0-f49.google.com with SMTP id c4so3381184eek.36
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2012 01:47:35 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefan/all.

Looking at possible values of dev->addr_assign_type I found out:

/* hardware address assignment types */
#define NET_ADDR_PERM          0       /* address is permanent (default) */
#define NET_ADDR_RANDOM                1       /* address is generated randomly */
#define NET_ADDR_STOLEN                2       /* address is stolen from other device */

By this it looks like dev->addr_assign_type value is always one of these 3.

But by the way the value is treated in dev_hw_addr_random() for example:
dev->addr_assign_type |= NET_ADDR_RANDOM;
It looks like NET_ADDR_* ought to be flags...

That confuses me.

Jiri

ps.: introduced in c1f79426e2df5ef96fe3e76de6c7606d15bf390b
