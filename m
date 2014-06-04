From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/4] net: Allow for more then a single subclass for
 netif_addr_lock
Date: Wed, 04 Jun 2014 14:53:44 -0700 (PDT)
Message-ID: <20140604.145344.1776321352568977848.davem@davemloft.net>
References: <1400274296-14765-1-git-send-email-vyasevic@redhat.com>
	<1400274296-14765-3-git-send-email-vyasevic@redhat.com>
	<1401918131.24086.9.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevic@redhat.com, netdev@vger.kernel.org,
	dingtianhong@huawei.com, vfalico@gmail.com, kaber@trash.net,
	jiri@resnulli.us
To: jacob.e.keller@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbaFDVxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 17:53:45 -0400
In-Reply-To: <1401918131.24086.9.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Date: Wed, 4 Jun 2014 21:42:12 +0000

> This only occurs if CONFIG_DEBUG_LOCK_ALLOC=Y, and there seems to be no
> easy fix for the warning, due to how spin_lock_nested is a macro that
> discards the second parameter when DEBUG_LOCK_ALLOC is disabled.

spin_lock_nested(), in that case, should mark the argument as unused.
