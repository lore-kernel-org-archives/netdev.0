From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 5/8] net/ncsi: Dump NCSI packet statistics
Date: Thu, 20 Apr 2017 13:21:03 -0400 (EDT)
Message-ID: <20170420.132103.454438573956782815.davem@davemloft.net>
References: <1492498295-14385-1-git-send-email-gwshan@linux.vnet.ibm.com>
        <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com, kubakici@wp.pl
To: gwshan@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45644 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S971561AbdDTRVF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 13:21:05 -0400
In-Reply-To: <1492498295-14385-6-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Date: Tue, 18 Apr 2017 16:51:32 +1000

> This creates /sys/kernel/debug/ncsi/<eth0>/stats to dump the NCSI
> packets sent and received over all packages and channels. It's useful
> to diagnose NCSI problems, especially when NCSI packages and channels
> aren't probed properly. The statistics can be gained from debugfs file
> as below:
> 
>  # cat /sys/kernel/debug/ncsi/eth0/stats

There is no reason you cannot use ethtool statistics to provide this
information to the user.
