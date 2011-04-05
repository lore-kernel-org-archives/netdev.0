From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: Allow no-cache copy from user on transmit
Date: Tue, 05 Apr 2011 04:56:40 -0700 (PDT)
Message-ID: <20110405.045640.133903374.davem@davemloft.net>
References: <alpine.DEB.2.00.1104042058370.18421@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37292
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752743Ab1DEL5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 07:57:19 -0400
In-Reply-To: <alpine.DEB.2.00.1104042058370.18421@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 4 Apr 2011 21:03:30 -0700 (PDT)

> This patch uses __copy_from_user_nocache on transmit to bypass data
> cache for a performance improvement.  skb_add_data_nocache and
> skb_copy_to_page_nocache can be called by sendmsg functions to use
> this feature, initial support is in tcp_sendmsg.  This functionality is
> configurable per device using ethtool.
 ...
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
