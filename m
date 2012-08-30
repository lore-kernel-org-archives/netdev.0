From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] l2tp: avoid to use synchronize_rcu in tunnel free
 function
Date: Thu, 30 Aug 2012 12:31:21 -0400 (EDT)
Message-ID: <20120830.123121.937893723287427746.davem@davemloft.net>
References: <1430615.YYms4uRCh4@dima>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kleptog@svana.org, jchapman@katalix.com
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753444Ab2H3QbZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:31:25 -0400
In-Reply-To: <1430615.YYms4uRCh4@dima>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kozlov Dmitry <xeb@mail.ru>
Date: Fri, 24 Aug 2012 15:07:38 +0400

> Avoid to use synchronize_rcu in l2tp_tunnel_free because context may be
> atomic.
> 
> Signed-off-by: Dmitry Kozlov <xeb@mail.ru>

Applied and queued up for -stable, thanks.
