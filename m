From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netpoll: warn on netpoll_send_udp users who
 haven't disabled irqs
Date: Fri, 28 Aug 2015 16:25:21 -0700 (PDT)
Message-ID: <20150828.162521.1289201883340955950.davem@davemloft.net>
References: <1440801865-9626-1-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: razor@blackwall.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56637 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbbH1XZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 19:25:22 -0400
In-Reply-To: <1440801865-9626-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <razor@blackwall.org>
Date: Fri, 28 Aug 2015 15:44:25 -0700

> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> Make sure we catch future netpoll_send_udp users who use it without
> disabling irqs and also as a hint for poll_controller users.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Excellent, applied, thanks.
