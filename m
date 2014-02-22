From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tipc: clean up components initialization code
Date: Sat, 22 Feb 2014 00:01:46 -0500 (EST)
Message-ID: <20140222.000146.781587367958127381.davem@davemloft.net>
References: <1392867171-31020-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	erik.hugne@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, wangweidong1@huawei.com
To: ying.xue@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46215 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750716AbaBVFBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Feb 2014 00:01:45 -0500
In-Reply-To: <1392867171-31020-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>
Date: Thu, 20 Feb 2014 11:32:48 +0800

> In this series, we will fix a regression issue involved by commit
> 6e967adf7(tipc: relocate common functions from media to bearer)
> But before the issue is fixed, we firstly adjust the process of
> components initialization so as to remove all enabled flags from
> necessary tipc components. Otherwise, without the change, we also
> have to add an extra enabled flag into bearer layer indicating
> whether bearer setup is finshed or not.
> 
> Ying Xue (2):
>   tipc: remove all enabled flags from all tipc components
>   tipc: make bearer set up in module insertion stage

Series applied, thanks.
