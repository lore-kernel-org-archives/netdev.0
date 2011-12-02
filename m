From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: flush route cache after change accept_local
Date: Thu, 01 Dec 2011 21:46:41 -0500 (EST)
Message-ID: <20111201.214641.1764261585752810377.davem@davemloft.net>
References: <20111201.125200.1219939487021672308.davem@davemloft.net>
	<ea4d82977e7726dccd8e8f8e65c7fb523668100e.1322790334.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40856 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab1LBCt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 21:49:26 -0500
In-Reply-To: <ea4d82977e7726dccd8e8f8e65c7fb523668100e.1322790334.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Fri,  2 Dec 2011 09:47:06 +0800

> After reset ipv4_devconf->data[IPV4_DEVCONF_ACCEPT_LOCAL] to 0,
> we should flush route cache, or it will continue receive packets with local
> source address, which should be dropped.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Applied, thanks.
