From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] qed/qede: Add tunneling support
Date: Fri, 15 Apr 2016 17:08:53 -0400 (EDT)
Message-ID: <20160415.170853.18623820706910466.davem@davemloft.net>
References: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Elior@qlogic.com,
	Yuval.Mintz@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52315 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbcDOVJA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 17:09:00 -0400
In-Reply-To: <1460612313-20323-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Thu, 14 Apr 2016 01:38:28 -0400

> This patch series adds support for VXLAN, GRE and GENEVE tunnels
> to be used over this driver. With this support, adapter can perform
> TSO offload, inner/outer checksums offloads on TX and RX for
> encapsulated packets.
> 
> V1->V2 [ Comments from Jesse Gross incorporated ]
> * Drop general infrastructure change patch.
>   "net: Make vxlan/geneve default udp ports public"
> * Remove by default Linux default UDP ports configurations in driver.
>   Instead, use general registration APIs for UDP port configurations
> * Removing .ndo_features_check - we will add it later with proper change.
> 
> Please consider applying this series to net-next.

Series applied, thanks.
