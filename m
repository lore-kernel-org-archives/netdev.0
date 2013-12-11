From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 05/12] bna: Enable Multi Buffer RX
Date: Wed, 11 Dec 2013 12:27:18 -0500 (EST)
Message-ID: <20131211.122718.1401456146385583996.davem@davemloft.net>
References: <1386745251-13710-1-git-send-email-rmody@brocade.com>
	<1386745251-13710-6-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@Brocade.COM
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab3LKR1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 12:27:21 -0500
In-Reply-To: <1386745251-13710-6-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Tue, 10 Dec 2013 23:00:44 -0800

> Using module parameter bnad_multi_buffer_rx this behavior can be reverted.

Sorry, I've told you guys a thousand times to use generic
configuration mechanisms, such as ethtool, to control behavior rather
than module parameters.

If the generic facility you need doesn't exist, make it, don't
do you own custom thing.
