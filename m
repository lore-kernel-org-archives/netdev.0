From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] 2.6.3 orinoco.c patch to support ethtool get_link
Date: Fri, 12 Mar 2004 10:53:56 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040312185356.GA5591@bougret.hpl.hp.com>
References: <20040308185242.GA18367@bougret.hpl.hp.com> <404E4159.9040404@tmus.dk> <4052063F.9020107@tmus.dk>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hermes@gibson.dropbear.id.au, netdev@oss.sgi.com,
        Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Munck Steenholdt <tmus@tmus.dk>
Content-Disposition: inline
In-Reply-To: <4052063F.9020107@tmus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 12, 2004 at 07:49:35PM +0100, Thomas Munck Steenholdt wrote:
> Thomas Munck Steenholdt wrote:
> >Jean Tourrilhes wrote:
> >
> >>    I hope you realise that most often link status is meaningless
> >>with Wireless cards. In Ad-Hoc mode, the link is always up, regardless
> >>of the number of nodes in the cell, check the discussion on the HostAP
> >>mailing list. And the Orinoco card will report connected even is WEP
> >>is wrong. But, if you only use managed mode without WEP, that should
> >>work.
> >>    I just wonder if it's better to report a 'link status' that
> >>may be wrong/misleading or to not report anything at all.
> >
> >
> >Actually, if the WEP key is wrong(i guess that's what you mean) the
> >link is determined as down, like it should be!
> >
> >For the AdHoc mode, sure the link is always determined as up, but that
> >is really the best way to do it given the nature of an Ad-Hoc network,
> >right!
> >
> >The way I see it you'll gain from this patch whenever in managed mode.
> >Most people (in my experience) is using managed mode and thus would 
> >benefit from this functionality!
> >
> >Thomas
> >
> >
> 
> Please comment on this ?
> 
> I feel it's a really good idea that would improve things for me a lot - 
> I'm sure I'm not the only one!
> 
> Thomas

	You need to talk to the driver maintainers. They have some
mailings lists.

	Jean
