From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] qlge: Fix receive packets drop.
Date: Fri, 18 Mar 2016 19:22:22 -0400 (EDT)
Message-ID: <20160318.192222.1189770801560142946.davem@davemloft.net>
References: <1458040425-12937-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-GELinuxNICDev@qlogic.com,
	harish.patil@qlogic.com
To: manish.chopra@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56435 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcCRXW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 19:22:27 -0400
In-Reply-To: <1458040425-12937-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>
Date: Tue, 15 Mar 2016 07:13:45 -0400

> When running small packets [length < 256 bytes] traffic, packets were
> being dropped due to invalid data in those packets which were
> delivered by the driver upto the stack. Using pci_dma_sync_single_for_cpu
> ensures copying latest and updated data into skb from the receive buffer.
> 
> Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
> Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>

Applied and queued up for -stable.
