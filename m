From: Hollis Blanchard <hollisb@us.ibm.com>
Subject: [PATCH 0 of 2] implement tty driver for netconsole
Date: Thu, 27 Nov 2008 15:11:00 -0600
Message-ID: <patchbomb.1227820260@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fall-lakeland.atl.sa.earthlink.net ([207.69.195.103]:51914 "EHLO
	fall-lakeland.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752364AbYK0VWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 16:22:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a Kuro Box (a small NAS device running Linux), and it has no serial
console (nor any other console for that matter). The most convenient way to get
boot output is via the netconsole driver, which is what most Kuro owners do. (The u-boot
firmware even supports interactive netconsole allowing us to edit boot configuration.)

However, once past kernel boot, userspace currently has no way of outputting data over
netconsole. These patches enable that, which is really useful for seeing init
script output and debugging ramdisks before they've brought up sshd.

-Hollis
