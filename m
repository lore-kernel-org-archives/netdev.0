From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] ifb: goto resched directly if error happens
 and dp->tq isn't empty
Date: Wed, 08 Dec 2010 09:45:52 -0800 (PST)
Message-ID: <20101208.094552.179947046.davem@davemloft.net>
References: <1291507748-4958-1-git-send-email-xiaosuo@gmail.com>
	<1291559144.2159.682.camel@mojatatu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, jarkao2@gmail.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57800
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752435Ab0LHRpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 12:45:24 -0500
In-Reply-To: <1291559144.2159.682.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 05 Dec 2010 09:25:44 -0500

> On Sun, 2010-12-05 at 08:09 +0800, Changli Gao wrote:
>> If we break the loop when there are still skbs in tq and no skb in
>> rq, the skbs will be left in txq until new skbs are enqueued into rq.
>> In rare cases, no new skb is queued, then these skbs will stay in rq
>> forever.
>> 
>> After this patch, if tq isn't empty when we break the loop, we goto
>> resched directly.
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
> 
> Dave, this goes to stable as well.

Applied and queued up for -stable, thanks.
