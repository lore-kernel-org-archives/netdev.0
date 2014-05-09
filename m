From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/5] qlcnic: Add support to process commands
 in atomic context
Date: Thu, 08 May 2014 23:39:46 -0400 (EDT)
Message-ID: <20140508.233946.1705263003595488483.davem@davemloft.net>
References: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
	<1399484378-22864-3-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: rajesh.borundia@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33035 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755936AbaEIDjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 23:39:48 -0400
In-Reply-To: <1399484378-22864-3-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Date: Wed, 7 May 2014 13:39:35 -0400

> -	netdev = (struct net_device *)entry->ptr;
> +	adapter = (struct qlcnic_adapter *)entry->ptr;

It is unnecessary to ever cast from a void pointer to something
else.

Please fix this and audit this issue in this entire patch series,
thank you.
