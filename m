From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] geneve: testing the wrong variable in
 geneve6_build_skb()
Date: Thu, 21 Apr 2016 14:08:19 -0400 (EDT)
Message-ID: <20160421.140819.672617348227733752.davem@davemloft.net>
References: <20160419143056.GD4876@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, jesse@kernel.org, linville@tuxdriver.com,
	pshelar@nicira.com, jbenc@redhat.com, daniel@iogearbox.net,
	tom@herbertland.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54147 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbcDUSIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 14:08:22 -0400
In-Reply-To: <20160419143056.GD4876@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 19 Apr 2016 17:30:56 +0300

> We intended to test "err" and not "skb".
> 
> Fixes: aed069df099c ('ip_tunnel_core: iptunnel_handle_offloads returns int and doesn't free skb')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
