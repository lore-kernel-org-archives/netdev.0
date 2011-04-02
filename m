From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Fri, 01 Apr 2011 20:49:22 -0700 (PDT)
Message-ID: <20110401.204922.28812273.davem@davemloft.net>
References: <alpine.DEB.2.00.1103302156270.17065@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33241
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751994Ab1DBDt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:49:59 -0400
In-Reply-To: <alpine.DEB.2.00.1103302156270.17065@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 30 Mar 2011 22:04:32 -0700 (PDT)

> This patch uses __copy_from_user_nocache (from skb_copy_to_page)
> on transmit to bypass data cache for a performance improvement.
> This functionality is configurable per device using ethtool.
...
> Signed-off-by: Tom Herbert <therbert@google.com>

It's early in net-next-2.6, so I've applied this now and we can
add any fixups and tweaks as needed.
