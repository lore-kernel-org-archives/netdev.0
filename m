From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 07/11] fs_enet: enable transmit time stamping.
Date: Sun, 19 Jun 2011 20:12:13 +0200
Message-ID: <20110619181212.GA3594@riccoc20.at.omicron.at>
References: <cover.1308481491.git.richard.cochran@omicron.at>
 <2a8677b99c6b8d0e34bbf0f6d6a44e6c7992636d.1308481492.git.richard.cochran@omicron.at>
 <1308484684.3539.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37564 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908Ab1FSSMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 14:12:12 -0400
Received: by fxm17 with SMTP id 17so549970fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 11:12:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1308484684.3539.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2011 at 01:58:04PM +0200, Eric Dumazet wrote:
> 
> Well, I'll stop my review here, there is the same problem I guess in all
> your patches.

Thanks for your review. I have posted a fix for the first batch (since
they are already in next) and reposted this series.

But, considering your point, it looks like pxa168_eth and mv643xx_eth
(see patches 9 and 10 of this series) already access skb->len unsafely.

Would you care to comment on those spots, too?

Thanks,
Richard
