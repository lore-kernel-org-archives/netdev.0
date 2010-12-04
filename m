From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 09:55:04 -0500
Message-ID: <1291474504.2159.39.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <4CFA3F01.20109@gmail.com> <1291472889.2159.18.camel@mojatatu>
	 <AANLkTimy_dK0uDCWqo3AZBKSvod+KnE6Om-CxrbFmPj+@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45163 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab0LDOzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:55:09 -0500
Received: by gyb11 with SMTP id 11so5288295gyb.19
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:55:09 -0800 (PST)
In-Reply-To: <AANLkTimy_dK0uDCWqo3AZBKSvod+KnE6Om-CxrbFmPj+@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 22:45 +0800, Changli Gao wrote:

> 
> If we breaks the loop when there are still skbs in tq and no skb in
> rq, the skbs will be left in txq until new skbs are enqueued into rq.
> In rare cases, no new skb is queued, then these skbs will stay in rq
> forever.

So should we goto resched? 

cheers,
jamal

