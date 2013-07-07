From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] bridge: fix some kernel warning in multicast
 timer
Date: Sat, 06 Jul 2013 18:27:45 -0700 (PDT)
Message-ID: <20130706.182745.1897575951543609771.davem@davemloft.net>
References: <1373024177-18191-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49262 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab3GGB1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Jul 2013 21:27:47 -0400
In-Reply-To: <1373024177-18191-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri,  5 Jul 2013 19:36:17 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Several people reported the warning: "kernel BUG at kernel/timer.c:729!"
> and the stack trace is:
 ...
> this is due to I forgot to check if mp->timer is armed in
> br_multicast_del_pg(). This bug is introduced by
> commit 9f00b2e7cf241fa389733d41b6 (bridge: only expire the mdb entry
> when query is received).
> 
> Same for __br_mdb_del().
> 
> Tested-by: poma <pomidorabelisima@gmail.com>
> Reported-by: LiYonghua <809674045@qq.com>
> Reported-by: Robert Hancock <hancockrwd@gmail.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
