From: =?gb2312?B?yerP/ru2?= <sxhlinux@163.com>
Subject: Questions about 'ip link set DEV_NAME name DEV_NEWNAME'
Date: Mon, 15 Jun 2015 21:25:30 +0800
Message-ID: <006101d0a76e$c2e800d0$48b80270$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:41751 "EHLO m50-132.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754074AbbFONZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 09:25:29 -0400
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm using command 'ip link set ge0/0 name ge5/1' to rename interface name
from ge0/0 to ge5/0. when command complete, command 'ifconfig' and 'cat
/proc/net/dev ' both can output information of ge5/0,however command 'ls
/sys/class/net/' output "ls: /sys/class/net/ge5/0: No such file or
directory".
     There is no udev in my device, until to now command 'ip link' is the
only way to change interface name. 
     Anyone know solution to my problem, please give me some advice, thanks!
