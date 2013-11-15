From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 1/4] r8152: fix tx/rx memory overflow
Date: Fri, 15 Nov 2013 17:39:48 -0500 (EST)
Message-ID: <20131115.173948.1712849813995511721.davem@davemloft.net>
References: <1384502279-9959-1-git-send-email-hayeswang@realtek.com>
	<1384502279-9959-2-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60271 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751689Ab3KOWjw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 17:39:52 -0500
In-Reply-To: <1384502279-9959-2-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hayes Wang <hayeswang@realtek.com>
Date: Fri, 15 Nov 2013 15:57:56 +0800

> +			unsigned pkt_len;

Please fully specify the type as "unsigned int".  Please check for this
problem in the rest of your patches too.

Thanks.
