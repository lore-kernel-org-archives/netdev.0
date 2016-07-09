From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] net: ip_finish_output_gso: If skb_gso_network_seglen
 exceeds MTU, do segmentation even for non IPSKB_FORWARDED skbs
Date: Sat, 9 Jul 2016 11:06:16 +0200
Message-ID: <20160709090616.GC2067@breakpoint.cc>
References: <1467722132-10084-1-git-send-email-shmulik.ladkani@ravellosystems.com>
 <20160705130327.GA10737@breakpoint.cc>
 <20160705170541.3f210675@pixies>
 <20160708.231206.2103933109393316831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shmulik.ladkani@ravellosystems.com, fw@strlen.de,
	edumazet@google.com, hannes@stressinduktion.org,
	shmulik.ladkani@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:36040 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932860AbcGIJG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jul 2016 05:06:26 -0400
Content-Disposition: inline
In-Reply-To: <20160708.231206.2103933109393316831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
> Date: Tue, 5 Jul 2016 17:05:41 +0300
> 
> > On Tue, 5 Jul 2016 15:03:27 +0200, fw@strlen.de wrote:
> >> (Or did I misunderstand this setup...?)
> > 
> > tap0 bridged with vxlan0.
> > route to vxlan0's remote peer is via eth0, configured with small mtu.
> 
> Florian, any more comments?

Sorry, I commented now.  But I'd really like to hear what vxlan experts
have to say about this, seems in RFC (7348) universe endpoint fragmention is
not supposed to happen :-/
