From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] netrom: fix invalid use of sizeof in nr_recvmsg()
Date: Mon, 08 Apr 2013 22:49:05 -0400 (EDT)
Message-ID: <20130408.224905.1206528635530811269.davem@davemloft.net>
References: <CAPgLHd-yEmt_BJ52uZNsCA_-w85VhnN_HbfjG1QLVvR5kp7Xvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, minipli@googlemail.com,
	yongjun_wei@trendmicro.com.cn, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, minipli@googlemail.com
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934603Ab3DICtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 22:49:09 -0400
In-Reply-To: <CAPgLHd-yEmt_BJ52uZNsCA_-w85VhnN_HbfjG1QLVvR5kp7Xvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 9 Apr 2013 10:07:19 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> sizeof() when applied to a pointer typed expression gives the size of the
> pointer, not that of the pointed data.
> Introduced by commit 3ce5ef(netrom: fix info leak via msg_name in nr_recvmsg)
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Any particular reason you're:

1) Targetting the wrong tree.  This was a bug fix that went into
   'net', therefore targetting -next is not correct.  This fix
   need to go into 'net'.

2) Not even bothering to CC: the person whose change you are
   correcting?

Anyways, applied to 'net', thanks.
