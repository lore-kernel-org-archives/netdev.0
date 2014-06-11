From: David Miller <davem@davemloft.net>
Subject: Re: some mac802154 fixes
Date: Wed, 11 Jun 2014 12:12:09 -0700 (PDT)
Message-ID: <20140611.121209.27447467678579224.davem@davemloft.net>
References: <1402480987-492-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: phoebe.buckheister@itwm.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46635 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751140AbaFKTMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 15:12:10 -0400
In-Reply-To: <1402480987-492-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Date: Wed, 11 Jun 2014 12:03:05 +0200

> Recent llsec code introduced a memory leak on decryption failures during rx.
> This fixes said leak, and optimizes the receive loops for monitor and wpan
> devices to only deliver skbs to devices that are actually up. Also changes a
> dev_kfree_skb to kfree_skb when an invalid packet is dropped before being
> pushed into the stack.

Series applied, thanks.

In header postings like this, please use the following format for your Subject
line:

	[PATCH 0/N] ${SUBSYSTEM}: Description

Thank you.
