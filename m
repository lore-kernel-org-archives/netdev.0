From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-2.6] ifb: goto resched directly if error happens
 and dp->tq isn't empty
Date: Sun, 05 Dec 2010 09:25:44 -0500
Message-ID: <1291559144.2159.682.camel@mojatatu>
References: <1291507748-4958-1-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:33262 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755285Ab0LEO0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Dec 2010 09:26:00 -0500
Received: by gyb11 with SMTP id 11so5570790gyb.19
        for <netdev@vger.kernel.org>; Sun, 05 Dec 2010 06:25:59 -0800 (PST)
In-Reply-To: <1291507748-4958-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2010-12-05 at 08:09 +0800, Changli Gao wrote:
> If we break the loop when there are still skbs in tq and no skb in
> rq, the skbs will be left in txq until new skbs are enqueued into rq.
> In rare cases, no new skb is queued, then these skbs will stay in rq
> forever.
> 
> After this patch, if tq isn't empty when we break the loop, we goto
> resched directly.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Dave, this goes to stable as well.

cheers,
jamal

