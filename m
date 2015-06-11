From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/3] enic: unlock napi busy poll before unmasking
 intr
Date: Wed, 10 Jun 2015 23:43:08 -0700 (PDT)
Message-ID: <20150610.234308.85292311787283551.davem@davemloft.net>
References: <1434003776-31840-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: _govind@gmx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58496 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbbFKGnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2015 02:43:09 -0400
In-Reply-To: <1434003776-31840-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <_govind@gmx.com>
Date: Thu, 11 Jun 2015 11:52:54 +0530

> There is a small window between vnic_intr_unmask() and enic_poll_unlock_napi().
> In this window if an irq occurs and napi is scheduled on different cpu, it tries
> to acquire enic_poll_lock_napi() and hits the following WARN_ON message.
> 
> Fix is to unlock napi_poll before unmasking the interrupt.
 ...
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>

Applied.
