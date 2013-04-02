From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] forcedeth: Do a dma_mapping_error check after
 skb_frag_dma_map
Date: Tue, 02 Apr 2013 14:32:51 -0400 (EDT)
Message-ID: <20130402.143251.957795421242273649.davem@davemloft.net>
References: <1364826718-16269-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760752Ab3DBScx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:32:53 -0400
In-Reply-To: <1364826718-16269-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon,  1 Apr 2013 10:31:58 -0400

> This backtrace was recently reported on a 3.9 kernel:
 ...
> Its pretty plainly the result of an skb fragment getting unmapped without having
> its initial mapping operation checked for errors.  This patch corrects that.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
