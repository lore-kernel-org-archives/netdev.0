From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] net: fix netdev features shift for features bit >
 31
Date: Sun, 21 Apr 2013 15:50:56 -0400 (EDT)
Message-ID: <20130421.155056.1845781789394372451.davem@davemloft.net>
References: <1366538974-4589-1-git-send-email-kaber@trash.net>
	<1366538974-4589-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amwang@redhat.com
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291Ab3DUTu6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Apr 2013 15:50:58 -0400
In-Reply-To: <1366538974-4589-2-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 21 Apr 2013 12:09:33 +0200

>    drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c: In function 'qlcnic_set_netdev_features':
>>> drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:967:7: warning: large integer implicitly truncated to unsigned type [-Woverflow]
> 
> This should be fixed by explicitly using 1ULL for the shifted value.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

The limitation is in the variable being assigned to, not the value
itself.

The "1" is already cast to a netdev_features_t by the macro
definition.
