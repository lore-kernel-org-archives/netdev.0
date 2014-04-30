From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] gianfar: Avoid unnecessary reg accesses in
 adjust_link()
Date: Wed, 30 Apr 2014 16:16:51 -0400 (EDT)
Message-ID: <20140430.161651.1135923239405605.davem@davemloft.net>
References: <1398857241-20137-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422770AbaD3UQw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2014 16:16:52 -0400
In-Reply-To: <1398857241-20137-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 30 Apr 2014 14:27:21 +0300

> For phy devices that don't issue interrupts upon link
> state changes, phylib polls the link state resulting in
> repeated calls to adjust_link(), even if the link state
> didn't change.  As a result, some mac registers are
> repeatedly read and written with the same values, which
> is not ok.
> 
> To fix this, adjust_link() has been refactored to check
> first whether the link state has changed and to take action
> only if needed, updating mac registers and local state
> variables.  The 'new_state' local flag, set if one of the
> link params changed (link, speed or duplex), has been
> rendered useless and removed by this refactoring.
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
