From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/6] net: cacheline adjust struct inet_frags
 for better frag performance
Date: Tue, 29 Jan 2013 08:30:01 +0100
Message-ID: <1359444601.7119.9.camel@localhost>
References: <20130124140343.14119.77712.stgit@dragon>
	 <20130124140417.14119.32738.stgit@dragon>
	 <20130128.232342.399301649354832893.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, netdev@vger.kernel.org,
	pablo@netfilter.org, amwang@redhat.com, kaber@trash.net,
	dborkman@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753849Ab3A2Hbs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 02:31:48 -0500
In-Reply-To: <20130128.232342.399301649354832893.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-28 at 23:23 -0500, David Miller wrote:
> From: Jesper Dangaard Brouer <brouer@redhat.com>
> Date: Thu, 24 Jan 2013 15:04:20 +0100
> 
> > +	/* --- read-mostly cacheline boundary (was 24 bytes ago) --- */
> 
> This "24" is context dependent, I assume it applies to 64-bit builds
> rather than 32-bit ones.

True

> Either add the necessary details or just get rid of this part of the
> comment altogether.

I'll remove the comment altogether, and resubmit the patchset.

Thanks for your review. (Hope your flu is gone, and your backlog didn't
grow too big)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
