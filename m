From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 04/16] i40e/i40evf: Move helper functions to a
 header file
Date: Thu, 20 Aug 2015 15:01:02 -0700 (PDT)
Message-ID: <20150820.150102.1875344338034277595.davem@davemloft.net>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1440032286-30054-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752137AbbHTWBD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 18:01:03 -0400
In-Reply-To: <1440032286-30054-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 19 Aug 2015 17:57:54 -0700

> +inline int i40e_allocate_dma_mem_d(struct i40e_hw *hw,
> +				   struct i40e_dma_mem *mem,
> +				   u64 size, u32 alignment)
> +{

All of these should be "static inline" otherwise GCC is going to emit
a copy every time you include this header file, even if it inlines all
of the call sites visible to it.
