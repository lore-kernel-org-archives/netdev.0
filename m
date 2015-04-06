From: Michael Cronenworth <mike@cchtml.com>
Subject: e1000e max frame calculation
Date: Mon, 06 Apr 2015 11:38:29 -0500
Message-ID: <5522B685.2030104@cchtml.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from que31.charter.net ([209.225.8.23]:57818 "EHLO que31.charter.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbbDFR1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 13:27:36 -0400
Received: from imp09 ([10.20.200.9]) by mta31.charter.net
          (InterMail vM.8.01.05.02 201-2260-151-103-20110920) with ESMTP
          id <20150406163830.FPVK10321.mta31.charter.net@imp09>
          for <netdev@vger.kernel.org>; Mon, 6 Apr 2015 12:38:30 -0400
Received: from impout002 ([68.114.189.17])
          by mtaout006.msg.strl.va.charter.net
          (InterMail vM.9.00.015.01 201-2473-143-101) with ESMTP
          id <20150406163830.OGNR22086.mtaout006.msg.strl.va.charter.net@impout002>
          for <netdev@vger.kernel.org>; Mon, 6 Apr 2015 11:38:30 -0500
Received: from mcronenworth.nhsrx.com (unknown [63.237.119.62])
	by cchtml.com (Postfix) with ESMTPSA id B0618154019B
	for <netdev@vger.kernel.org>; Mon,  6 Apr 2015 11:38:29 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have attempted to discuss this with upstream directly[1], but they will not 
respond to me. I will now attempt here.

The e1000e driver uses a different maximum frame calculation after a commit[2] in 
kernel 3.15. This caused everyone's setups that were using 9000 for MTU to break 
after they rebooted on their kernel update. The addition of the VLAN bytes force 
users to use 8996.

Other drivers appear to be using the "old" maximum frame calculation and can 
continue to use 9000.

Can a standard be decided upon that all drivers use or is it acceptable that one 
driver "does its own thing?"

Thanks,
Michael


[1] https://sourceforge.net/p/e1000/bugs/459/
[2] 
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/drivers/net/ethernet/intel/e1000e/netdev.c?id=c751a3d58cf2dae89ec941a259025b0175d67b0c
