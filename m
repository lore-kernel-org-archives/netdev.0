From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: [PATCH net v2 0/2] Fix RTNL: assertion failed at
 net/core/rtnetlink.c
Date: Wed, 19 Feb 2014 11:52:00 +0100
Message-ID: <20140219105200.GA18298@glanzmann.de>
References: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	cwang@twopensource.com, jiri@resnulli.us, eric.dumazet@gmail.com,
	sfeldma@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([88.198.249.254]:48594 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaBSKwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 05:52:03 -0500
Content-Disposition: inline
In-Reply-To: <1392800711-19264-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ding,

> v1->v2: Add new micro to indicate that the notification should be send
> 	later, not never.
> 	And add a new patch to fix the same problem for ARP mode.

> Ding Tianhong (2):
>   bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for
>     802.3ad mode
>   bonding: Fix RTNL: assertion failed at net/core/rtnetlink.c for ab
>     arp monitor

the patch did not apply cleanly for me, so I manually merged it.

The resulting patch is here:

(node-62) [~/work/linux-2.6] git diff | pbot
http://pbot.rmdir.de/TDMvhGB775BVPpKvm6NOXg

Find the results here:

(node-62) [~] dmesg | pbot
http://pbot.rmdir.de/nogPmqfGRxxk9zMNBlr0QQ
(node-62) [~] pbot /proc/net/bonding/bond0
http://pbot.rmdir.de/zNSSqmjSI0o1Qvt6DrSEQw
(node-62) [~] pbot /proc/net/bonding/bond1
http://pbot.rmdir.de/CoI00Rguie2P-kOQytOM9w

Tested-by: Thomas Glanzmann <thomas@glanzmann.de>

Cheers,
        Thomas
