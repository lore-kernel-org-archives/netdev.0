From: Nix <nix@esperi.org.uk>
Subject: Re: [2.6.17.8] NFS stall / BUG in UDP fragment processing / SKB trimming
Date: Sun, 13 Aug 2006 19:24:33 +0100
Message-ID: <87wt9cqyse.fsf@hades.wkstn.nix>
References: <87zme9fy94.fsf@hades.wkstn.nix>
	<20060813125910.GA18463@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	linux-kernel@vger.kernel.org, Neil Brown <neilb@suse.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 41-052.adsl.zetnet.co.uk ([194.247.41.52]:48914 "EHLO
	mail.esperi.org.uk") by vger.kernel.org with ESMTP id S1750718AbWHMSZP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Aug 2006 14:25:15 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060813125910.GA18463@gondor.apana.org.au> (Herbert Xu's message of "Sun, 13 Aug 2006 22:59:11 +1000")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 13 Aug 2006, Herbert Xu suggested tentatively:
> Oops, I missed this code path when I disallowed skb_trim from operating
> on a paged skb.  This patch should fix the problem.
> 
> Greg, we need this for 2.6.17 stable as well if Dave is OK with it.
> 
> [INET]: Use pskb_trim_unique when trimming paged unique skbs
[...]

Yes, that seems to have fixed it. Thank you!

-- 
`We're sysadmins. We deal with the inconceivable so often I can clearly 
 see the need to define levels of inconceivability.' --- Rik Steenwinkel
