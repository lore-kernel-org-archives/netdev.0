From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: rx: frames received out of order
Date: Tue, 02 Aug 2016 09:49:53 +0200
Message-ID: <1470124193.2665.13.camel@sipsolutions.net>
References: <20160713115758.25395-1-yanivma@ti.com>
	 (sfid-20160713_135411_110427_3A917D6E)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Meirav Kama <meiravk@ti.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Yaniv Machani <yanivma@ti.com>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:40051 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932146AbcHBIcN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 04:32:13 -0400
In-Reply-To: <20160713115758.25395-1-yanivma@ti.com> (sfid-20160713_135411_110427_3A917D6E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-07-13 at 14:57 +0300, Yaniv Machani wrote:
> From: Meirav Kama <meiravk@ti.com>
> 
> Upon forwarding frames from Rx to Tx in mesh, driver clones the skb.
> It zeros the tx_info and doesn't set hw_queue correctly. It then
> enqueues
> the frame in queue 0 (VOICE) instead of the correct queue.
> Upon re-queue of this frame, driver inserts it to the correct queue
> (e.g. BE).
> After that, driver dequeue frames from 2 different queues and sends
> them out of order.
> To fix this, driver will set the tx_info->hw_queue to the correct
> queue when cloning the skb.
> 
Makes sense, but the subject is a bit misleading - can you come up with
a better one?

johannes
