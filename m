From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/13] bna: SKB Check and Drop Macros
Date: Sat, 20 Aug 2011 11:05:07 -0700 (PDT)
Message-ID: <20110820.110507.292184051848114840.davem@davemloft.net>
References: <1313789972-22711-1-git-send-email-rmody@brocade.com>
	<1313789972-22711-5-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com,
	gkaraje@brocade.com
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56139 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173Ab1HTSGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 14:06:09 -0400
In-Reply-To: <1313789972-22711-5-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Fri, 19 Aug 2011 14:39:23 -0700

> Add macros to check and drop skb from transmit path and return.
> 
> Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>

Do not EVER create macros that have the side effect of doing
a function return.

This makes code impossible to read and audit, because it is not
possible to see just by looking at the macro invocation that the
function might be returned from what at that moment.

