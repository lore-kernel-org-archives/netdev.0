From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlcnic: add missing destroy_workqueue() on error path
 in qlcnic_probe()
Date: Tue, 08 Oct 2013 16:53:31 -0400 (EDT)
Message-ID: <20131008.165331.2160507422250866015.davem@davemloft.net>
References: <CAPgLHd9oA08=1o_DWE0SGeg_7nokr3-WPEAOrG71bYg2C1676A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com,
	yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55318 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756790Ab3JHUxe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 16:53:34 -0400
In-Reply-To: <CAPgLHd9oA08=1o_DWE0SGeg_7nokr3-WPEAOrG71bYg2C1676A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 8 Oct 2013 11:32:17 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Add the missing destroy_workqueue() before return from
> qlcnic_probe() in the error handling case.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
