From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: [PATCH net-next 0/3] bonding: Fix RTNL: assertion failed at
 net/core/rtnetlink.c
Date: Mon, 17 Feb 2014 15:06:11 +0100
Message-ID: <20140217140611.GC6211@glanzmann.de>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	cwang@twopensource.com, jiri@resnulli.us, eric.dumazet@gmail.com,
	sfeldma@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([88.198.249.254]:45566 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaBQOGQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 09:06:16 -0500
Content-Disposition: inline
In-Reply-To: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ding,

>   bonding: add bond_set_slave_state/flags()
>   bonding: add new slave param and  bond_slave_state_notify()
>   bonding: Fix the RTNL assertion failed for 802.3ad state machine

I applied the three patches on top of current Linus tip and recompiled,
my problems are gone. Find here dmesg and output of
/proc/net/bonding/bond?

(node-62) [~] dmesg | pbot
http://pbot.rmdir.de/pSIH_mE3PguPWsEYdVgusg
(node-62) [~] pbot /proc/net/bonding/bond0
http://pbot.rmdir.de/zNSSqmjSI0o1Qvt6DrSEQw
(node-62) [~] pbot /proc/net/bonding/bond1
http://pbot.rmdir.de/CoI00Rguie2P-kOQytOM9w

Tested-by: Thomas Glanzmann <thomas@glanzmann.de>

Cheers,
        Thomas
