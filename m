From: Christian Kujau <lists@nerdbynature.de>
Subject: RTNL: assertion failed at net/core/dev.c
Date: Sun, 2 Sep 2007 18:05:33 +0200 (CEST)
Message-ID: <alpine.DEB.0.999.0709021754290.7103@sheep.housecafe.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.g-housing.de ([81.169.133.75]:35070 "EHLO mail.g-house.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755081AbXIBQFh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Sep 2007 12:05:37 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wow, I should really update more often. Skipping the last -rc versions 
AND adding a new device (zd1211rw) to the box turns out to be quite 
interesting ([0],[1]).

However, this time loading of a (proprietary) module is involved. Knowing
that lkml cannot really help here (and I should contact vmware), I just 
wanted to let you netdev guys know, because the only occurences I found 
on the net were from 1999, but given the amount of changes currently 
going into net/ I thought this might be interesting:

[15604.137408] RTNL: assertion failed at net/core/dev.c (2595)
[15604.137772]  [<c0106aaa>] show_trace_log_lvl+0x1a/0x30
[15604.138121]  [<c0107682>] show_trace+0x12/0x20
[15604.138449]  [<c01076a5>] dump_stack+0x15/0x20
[15604.138807]  [<c038c612>] __dev_set_promiscuity+0xc2/0xd0
[15604.139163]  [<c038c9bb>] dev_set_promiscuity+0x1b/0x40
[15604.139515]  [<f91cb3fb>] VNetBridgeStartPromisc+0x2b/0x50 [vmnet]
[15604.139896]  [<f91cb61a>] VNetBridgePortsChanged+0x2a/0x40 [vmnet]
[15604.140276]  [<f91c9a65>] VNetHubPortsChanged+0x65/0xc0 [vmnet]
[15604.140648]  [<f91c869a>] VNetConnect+0x7a/0xb0 [vmnet]
[15604.141000]  [<f91c926d>] VNetFileOpOpen+0xbd/0x170 [vmnet]
[15604.141362]  [<c016b213>] chrdev_open+0x83/0x180
[15604.141696]  [<c0167321>] __dentry_open+0xa1/0x1a0
[15604.142036]  [<c01674c5>] nameidata_to_filp+0x35/0x40
[15604.142383]  [<c0167519>] do_filp_open+0x49/0x60
[15604.142717]  [<c0167575>] do_sys_open+0x45/0x80
[15604.142957]  [<c01675ec>] sys_open+0x1c/0x20
[15604.143087]  [<c010598a>] sysenter_past_esp+0x6b/0xb5
[15604.143227]  =======================

details: http://nerdbynature.de/bits/2.6.23-rc5/

Christian.

[0] http://www.spinics.net/lists/netdev/msg40247.html
[1] http://www.spinics.net/lists/netdev/msg40281.html
-- 
BOFH excuse #31:

cellular telephone interference
