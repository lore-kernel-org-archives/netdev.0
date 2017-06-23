From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PATCH v3 Convert multiple netdev_info messages to
 netdev_dbg
Date: Fri, 23 Jun 2017 13:33:52 -0400 (EDT)
Message-ID: <20170623.133352.2059206023839972118.davem@davemloft.net>
References: <1498010934-27703-1-git-send-email-michael.j.dilmore@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        joe@perches.com
To: michael.j.dilmore@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498010934-27703-1-git-send-email-michael.j.dilmore@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael J Dilmore <michael.j.dilmore@gmail.com>
Date: Wed, 21 Jun 2017 03:08:54 +0100

> The bond_options.c file contains multiple netdev_info messages that
> clutter kernel output. This patches replaces these with netdev_dbg messages
> and adds a netdev_dbg for packets for slave.
> 
> Signed-off-by: Michael J Dilmore <michael.j.dilmore@gmail.com>
> Suggested-by: Joe Perches <joe@perches.com>

This falls under the category of "very low quality patch submission"
I'm afraid.

First of all your Subject lines need to be done more properly.

Puting "PATCH" twice in there is pointless, just once inside of the
brackets is enough.  The "v3" belongs inside of the brackets too.

Seriously, just look at how other developer format their Subject lines
on this mailing list, and you are less likely to go wrong.  Doing thing
your own unique way is asking for trouble.

But more importantly, your commit log message says you are converting
netdev_info calls into netdev_dbg ones, but that is not at all what
this patch does.

>  		netdev_dbg(bond->dev, "%s mode is incompatible with arp monitoring, start mii monitoring\n",
> -			    newval->string);
> +			   newval->string);

You're simply adjusting indentation of the code.

There are no "conversions" going on here at all.
