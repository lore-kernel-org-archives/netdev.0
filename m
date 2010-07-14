From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rfs: call sock_rps_record_flow() in tcp_splice_read()
Date: Wed, 14 Jul 2010 14:45:27 -0700 (PDT)
Message-ID: <20100714.144527.28803131.davem@davemloft.net>
References: <1279004412-11094-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com,
	netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59951
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757277Ab0GNVpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 17:45:13 -0400
In-Reply-To: <1279004412-11094-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Tue, 13 Jul 2010 15:00:12 +0800

> rfs: call sock_rps_record_flow() in tcp_splice_read()
> 
> call sock_rps_record_flow() in tcp_splice_read(), so the applications using
> splice(2) or sendfile(2) can utilize RFS.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied, thanks.
