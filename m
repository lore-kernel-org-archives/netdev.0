From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Subject: [RFC][PATCH -mm 0/9] netconsole: Multiple targets and dynamic reconfigurability
Date: Wed, 04 Jul 2007 16:37:39 +0530
Message-ID: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Satyam Sharma <ssatyam@cse.iitk.ac.in>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Matt Mackall <mpm@selenic.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.iitk.ac.in ([203.197.196.4]:57173 "EHLO mail4.iitk.ac.in"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761020AbXGDLIG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 07:08:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Satyam Sharma <ssatyam@cse.iitk.ac.in>

[0/9] netconsole: Multiple targets and dynamic reconfigurability

This patchset is a rework of the original idea and patches posted by
Keiichi Kii and Takayoshi Kochi at: http://lkml.org/lkml/2007/6/13/72

[ I had initially thought about only modifying Keiichi's patches to
incorporate the suggested stuff, sysfs+ioctl->configfs conversion, etc,
but the changes became too much and I ultimately ended up rewriting the
patchset. This also gave the flexibility to make other changes possible.
Keiichi, Takayoshi, kindly review this, and if OK, please give your
Signed-off-by:'s to the patches herein. ]

This patchset depends upon the earlier netpoll fixlet and the configfs
cleanup patches. Diffed against 2.6.22-rc6-mm1.

[1/9] netconsole: Cleanups, codingstyle, prettyfication
[2/9] netconsole: Code simplification
[3/9] netconsole: Introduce netconsole_target
[4/9] netconsole: Introduce netconsole_netdev_notifier
[5/9] netconsole: Introduce dev_status member
[6/9] netconsole: Update documentation for multiple target support
[7/9] netconsole: Support multiple logging targets
[8/9] netconsole: Update documentation for dynamic reconfigurability
[9/9] netconsole: Support dynamic reconfiguration using configfs

Signed-off-by: Satyam Sharma <ssatyam@cse.iitk.ac.in>

About this patchset:
====================

What?

Support multiple remote logging targets in netconsole. Also, ability to
dynamically add or remove targets or modify parameters (IP, port, remote
MAC address) of targets at runtime, from userspace, using configfs.

Why?

>From Keiichi Kii's original post:

[...] current netconsole is not flexible. For example, if you want to change
ip address for logging agent, in the case of built-in netconsole, you can't
change config except for changing boot parameter and rebooting your system,
or in the case of module netconsole, you need to remove it and reload
with different parameters. [...] and we have been losing serial console
port with PCs and Servers.

(... and especially laptops, I would add.)

The patchset is heavily commented and verbosely changelogged, so hope you
have as much fun reading and reviewing it as I had writing it :-)

Kindly review and comment.

Satyam
