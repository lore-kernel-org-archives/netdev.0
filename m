From: Thomas Glanzmann <thomas@glanzmann.de>
Subject: Re: [PATCH net v3 0/2] Fix RTNL: assertion failed at
 net/core/rtnetlink.c
Date: Wed, 26 Feb 2014 10:40:25 +0100
Message-ID: <20140226094024.GG5077@glanzmann.de>
References: <1393383923-40876-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, vfalico@redhat.com, andy@greyhouse.net,
	cwang@twopensource.com, jiri@resnulli.us, eric.dumazet@gmail.com,
	sfeldma@cumulusnetworks.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from infra.glanzmann.de ([88.198.249.254]:58798 "EHLO
	infra.glanzmann.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811AbaBZJk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 04:40:27 -0500
Content-Disposition: inline
In-Reply-To: <1393383923-40876-1-git-send-email-dingtianhong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ding,
the patch did not apply for me cleanly against Linus tip, so I manually
merged it. The resulting patch is here:

http://pbot.rmdir.de/wHFa0-bLDuVEIT-5lnbIrQ

I tested it:

(node-62) [~] dmesg | pbot
http://pbot.rmdir.de/QeWgt5TNhISgRpENt6pCIg
(node-62) [~] pbot /proc/net/bonding/bond0
http://pbot.rmdir.de/zNSSqmjSI0o1Qvt6DrSEQw
(node-62) [~] pbot /proc/net/bonding/bond1
http://pbot.rmdir.de/CoI00Rguie2P-kOQytOM9w

Tested-by: Thomas Glanzmann <thomas@glanzmann.de>

Cheers,
        Thomas
