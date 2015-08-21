From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 1179/1189] include/linux/compiler.h:447:38:
 error: call to '__compiletime_assert_243' declared with attribute error:
 BUILD_BUG_ON failed: offsetof(struct dst_entry, __refcnt) & 63
Date: Thu, 20 Aug 2015 23:26:50 -0700 (PDT)
Message-ID: <20150820.232650.1503466109554752010.davem@davemloft.net>
References: <201508211329.x7P0JrxH%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59544 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbbHUG0x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 02:26:53 -0400
In-Reply-To: <201508211329.x7P0JrxH%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Yeah, I should have predicted this would happen on 32-bit builds when I saw
the adjustment of __pad_to_align_refcnt[] for 64-bit.

Jiri, you might not have any reasonable options to fix this I'm afraid.
