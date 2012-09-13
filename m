From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] netfilter updates for 3.6-rc5
Date: Thu, 13 Sep 2012 14:25:31 -0400 (EDT)
Message-ID: <20120913.142531.1141106551750112538.davem@davemloft.net>
References: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48060 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2IMSZe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:25:34 -0400
In-Reply-To: <1347533648-3451-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Thu, 13 Sep 2012 12:54:04 +0200

> The following patchset contains four updates for your net tree, they are:
> 
> * Fix crash on timewait sockets, since the TCP early demux was added,
>   in nfnetlink_log, from Eric Dumazet.
> 
> * Fix broken syslog log-level for xt_LOG and ebt_log since printk format was
>   converted from <.> to a 2 bytes pattern using ASCII SOH, from Joe Perches.
> 
> * Two security fixes for the TCP connection tracking targeting off-path attacks,
>   from Jozsef Kadlecsik. The problem was discovered by Jan Wrobel and it is
>   documented in: http://mixedbit.org/reflection_scan/reflection_scan.pdf.
> 
> You can pull these changes from:
> 
> git://1984.lsi.us.es/nf master

Pulled, thanks Pablo.
