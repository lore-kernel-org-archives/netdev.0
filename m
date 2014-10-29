From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/3] Fix the way the local advertising flow
 options are determined
Date: Wed, 29 Oct 2014 14:33:42 -0400 (EDT)
Message-ID: <20141029.143342.40516574588339612.davem@davemloft.net>
References: <1414399364-22308-1-git-send-email-matei.pavaluca@freescale.com>
	<1414399364-22308-2-git-send-email-matei.pavaluca@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, claudiu.manoil@freescale.com
To: matei.pavaluca@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321AbaJ2Sdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 14:33:45 -0400
In-Reply-To: <1414399364-22308-2-git-send-email-matei.pavaluca@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matei Pavaluca <matei.pavaluca@freescale.com>
Date: Mon, 27 Oct 2014 10:42:43 +0200

> From: Pavaluca Matei-B46610 <matei.pavaluca@freescale.com>
> 
> Local flow control options needed in order to resolve the negotiation
> are incorrectly calculated.
> 
> Previously 'mii_advertise_flowctrl' was called to determine the local advertising
> options, but these were determined based on FLOW_CTRL_RX/TX flags which are
> never set through ethtool.
> The patch simply translates from ethtool flow options to mii flow options.
> 
> Signed-off-by: Pavaluca Matei <matei.pavaluca@freescale.com>

Applied.
