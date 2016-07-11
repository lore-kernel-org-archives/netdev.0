From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Mon, 11 Jul 2016 10:15:11 +0200
Message-ID: <20160711081511.GG2067@breakpoint.cc>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc>
 <20160705170541.3f210675@pixies>
 <20160709090020.GB2067@breakpoint.cc>
 <20160709153017.791f2607@halley>
 <20160709132230.GD2067@breakpoint.cc>
 <20160710105120.72d80371@pixies>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:37373 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753319AbcGKIPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 04:15:19 -0400
Content-Disposition: inline
In-Reply-To: <20160710105120.72d80371@pixies>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> OK with the general idea; However I don't want to abuse IPSKB_FORWARDED
> as the skb is not really "ip forwarded", and it might have undesirable
> affects, such as in 'ip_skb_dst_mtu' which follows.

I don't see a problem with that. Hannes?
