From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: Correctly return -EBADF from
 pppol2tp_getname.
Date: Tue, 26 Jul 2016 15:19:57 -0700 (PDT)
Message-ID: <20160726.151957.1214443852703588578.davem@davemloft.net>
References: <20160726191435.31503-1-phil.turnbull@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: phil.turnbull@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41910 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434AbcGZWT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 18:19:59 -0400
In-Reply-To: <20160726191435.31503-1-phil.turnbull@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Turnbull <phil.turnbull@oracle.com>
Date: Tue, 26 Jul 2016 15:14:35 -0400

> If 'tunnel' is NULL we should return -EBADF but the 'end_put_sess' path
> unconditionally sets 'error' back to zero. Rework the error path so it
> more closely matches pppol2tp_sendmsg.
> 
> Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
> Signed-off-by: Phil Turnbull <phil.turnbull@oracle.com>

Applied.
