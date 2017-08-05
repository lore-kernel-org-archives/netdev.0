From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net: dsa: assign switch device in legacy
 code
Date: Sat, 5 Aug 2017 02:55:26 +0200
Message-ID: <20170805005526.GA19193@lunn.ch>
References: <20170804222320.10986-1-vivien.didelot@savoirfairelinux.com>
 <20170804222320.10986-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52669 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750945AbdHEAzc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Aug 2017 20:55:32 -0400
Content-Disposition: inline
In-Reply-To: <20170804222320.10986-2-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -251,8 +251,9 @@ dsa_switch_setup(struct dsa_switch_tree *dst, struct net_device *master,
>  	ds->cd = cd;
>  	ds->ops = ops;
>  	ds->priv = priv;
> +	ds->dev = parent;

Hi Vivien

Is this even needed? dsa_switch_alloc() does ds->dev = dev.

   Andrew
