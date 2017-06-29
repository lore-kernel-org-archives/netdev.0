From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Fix assignment of RX/TX IRQ's
Date: Thu, 29 Jun 2017 15:44:19 -0400 (EDT)
Message-ID: <20170629.154419.1976803371578783974.davem@davemloft.net>
References: <1498697754-17019-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45134 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752111AbdF2ToV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:44:21 -0400
In-Reply-To: <1498697754-17019-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 28 Jun 2017 19:55:54 -0500

> The driver currently creates RX/TX queues during device probe, but
> assigns IRQ's to them during device open. On reset, however,
> IRQ's are assigned when resetting the queues. If there is a reset
> while the device is closed and the device is later opened, the driver will
> request IRQ's twice, causing the open to fail. This patch assigns
> the IRQ's in the ibmvnic_init function after the queues are reset or
> initialized, ensuring IRQ's are only requested once.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied, thanks Thomas.
