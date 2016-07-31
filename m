From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sctp: fix the issue sctp requeue auth chunk
 incorrectly
Date: Sat, 30 Jul 2016 22:06:52 -0700 (PDT)
Message-ID: <20160730.220652.1863192062471461146.davem@davemloft.net>
References: <af1555c524101278be2e5b07ff78a1eaacc0f7bb.1469858315.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750901AbcGaFHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jul 2016 01:07:15 -0400
In-Reply-To: <af1555c524101278be2e5b07ff78a1eaacc0f7bb.1469858315.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 30 Jul 2016 13:58:35 +0800

> sctp needs to queue auth chunk back when we know that we are going
> to generate another segment. But commit f1533cce60d1 ("sctp: fix
> panic when sending auth chunks") requeues the last chunk processed
> which is probably not the auth chunk.
> 
> It causes panic when calculating the MAC in sctp_auth_calculate_hmac(),
> as the incorrect offset of the auth chunk in skb->data.
> 
> This fix is to requeue it by using packet->auth.
> 
> Fixes: f1533cce60d1 ("sctp: fix panic when sending auth chunks")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
