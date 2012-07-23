From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid oops in tcp_metrics and reset tcpm_stamp
Date: Mon, 23 Jul 2012 00:58:09 -0700 (PDT)
Message-ID: <20120723.005809.730802545667962757.davem@davemloft.net>
References: <1343029598-4975-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42863 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389Ab2GWH6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 03:58:12 -0400
In-Reply-To: <1343029598-4975-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 23 Jul 2012 10:46:38 +0300

> 	In tcp_tw_remember_stamp we incorrectly checked tw
> instead of tm, it can lead to oops if the cached entry is
> not found.
> 
> 	tcpm_stamp was not updated in tcpm_check_stamp when
> tcpm_suck_dst was called, move the update into tcpm_suck_dst,
> so that we do not call it infinitely on every next cache hit
> after TCP_METRICS_TIMEOUT.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied, thanks Julian.
