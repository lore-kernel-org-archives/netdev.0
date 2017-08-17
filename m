From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] dsa: remove unused net_device arg from handlers
Date: Thu, 17 Aug 2017 20:21:16 +0200
Message-ID: <20170817182116.GE21715@lunn.ch>
References: <20170817144700.16218-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:33918 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753327AbdHQSVT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 14:21:19 -0400
Content-Disposition: inline
In-Reply-To: <20170817144700.16218-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 17, 2017 at 04:47:00PM +0200, Florian Westphal wrote:
> compile tested only, but saw no warnings/errors with
> allmodconfig build.
>  
>  static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
> -			  struct packet_type *pt, struct net_device *orig_dev)
> +			  struct packet_type *pt, struct net_device *unused)

Hi Florian

Looks O.K. to me. I can test it out later.

Is there a bigger picture here? Do you plan to remove the second
net_device parameter everywhere?

	   Andrew
