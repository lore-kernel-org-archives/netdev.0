From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] openvswitch: Fix alignment of struct sw_flow_key.
Date: Thu, 05 Sep 2013 15:54:53 -0400 (EDT)
Message-ID: <20130905.155453.1868210686010920876.davem@davemloft.net>
References: <1378408625-18415-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, azhou@nicira.com,
	fengguang.wu@intel.com, geert@linux-m68k.org
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753092Ab3IETyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 15:54:55 -0400
In-Reply-To: <1378408625-18415-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Gross <jesse@nicira.com>
Date: Thu,  5 Sep 2013 12:17:05 -0700

> sw_flow_key alignment was declared as " __aligned(__alignof__(long))".
> However, this breaks on the m68k architecture where long is 32 bit in
> size but 16 bit aligned by default. This aligns to the size of a long to
> ensure that we can always do comparsions in full long-sized chunks. It
> also adds an additional build check to catch any reduction in alignment.
> 
> CC: Andy Zhou <azhou@nicira.com>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Jesse Gross <jesse@nicira.com>

Applied, thanks.
