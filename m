From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Sun, 03 Apr 2011 22:03:05 -0700 (PDT)
Message-ID: <20110403.220305.71570981.davem@davemloft.net>
References: <alpine.DEB.2.00.1104032136540.5452@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53090
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751021Ab1DDFDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 01:03:42 -0400
In-Reply-To: <alpine.DEB.2.00.1104032136540.5452@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 3 Apr 2011 21:56:17 -0700 (PDT)

> This patch uses __copy_from_user_nocache on transmit to bypass data
> cache for a performance improvement.  skb_add_data_nocache and
> skb_copy_to_page_nocache can be called by sendmsg functions to use
> this feature, initial support is in tcp_sendmsg.  This functionality is
> configurable per device using ethtool.
 ...
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied, thanks Tom.
