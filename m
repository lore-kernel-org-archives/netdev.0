From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] allow device to stop packet mirror behaviour
Date: Tue, 07 Aug 2007 18:06:07 -0700 (PDT)
Message-ID: <20070807.180607.116354128.davem@davemloft.net>
References: <1186475155.4067.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@warmcat.com,
	linux-wireless@vger.kernel.org
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55717
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758220AbXHHBGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:06:07 -0400
In-Reply-To: <1186475155.4067.17.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 07 Aug 2007 10:25:55 +0200

> The only way to solve this problem therefore seems to be to suppress the
> mirroring out of the packet by dev_queue_xmit_nit(). The patch below
> does that by way of adding a new netdev flag.

Multicast packets also get looped back in a similar manner in the ipv4
code.  These will also be seen twice due to this issue.

There are probably many other examples as well, dev_queue_xmit_nit()
is just the tip of the iceberg.
