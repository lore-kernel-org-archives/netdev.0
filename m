From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] qeth: fix VLAN related compilation errors
Date: Sun, 21 Apr 2013 15:58:44 -0400 (EDT)
Message-ID: <20130421.155844.1335490646824126162.davem@davemloft.net>
References: <1366538974-4589-1-git-send-email-kaber@trash.net>
	<1366538974-4589-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50191 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226Ab3DUT6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 15:58:46 -0400
In-Reply-To: <1366538974-4589-3-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 21 Apr 2013 12:09:34 +0200

>    drivers/s390/net/qeth_l3_main.c: In function 'qeth_l3_add_vlan_mc':
>>> drivers/s390/net/qeth_l3_main.c:1662:3: error: too few arguments to function '__vlan_find_dev_deep'
>    include/linux/if_vlan.h:88:27: note: declared here
 ...
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
