From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: use list_move_tail instead of
 list_del/list_add_tail
Date: Wed, 05 Sep 2012 17:50:30 -0400 (EDT)
Message-ID: <20120905.175030.1704357444804465147.davem@davemloft.net>
References: <CAPgLHd-P-x3ZqrUMirMBbx74vz1XXNLb-nb3UWa43nVmmwNMCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, yongjun_wei@trendmicro.com.cn,
	netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759604Ab2IEVuc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Sep 2012 17:50:32 -0400
In-Reply-To: <CAPgLHd-P-x3ZqrUMirMBbx74vz1XXNLb-nb3UWa43nVmmwNMCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 5 Sep 2012 15:06:55 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> Using list_move_tail() instead of list_del() + list_add_tail().
> 
> spatch with a semantic match is used to found this problem.
> (http://coccinelle.lip6.fr/)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied.
