From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [PATCH] 2.6.3 orinoco.c patch to support ethtool get_link
Date: Tue, 16 Mar 2004 11:14:32 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040316001432.GA19983@zax>
References: <20040308185242.GA18367@bougret.hpl.hp.com> <404E4159.9040404@tmus.dk> <4052063F.9020107@tmus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>
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
> 
> Please comment on this ?
> 
> I feel it's a really good idea that would improve things for me a lot - 
> I'm sure I'm not the only one!

Sorry, I've been distracted by other things and haven't gotten around
to replying to this.  I see that Pavel Roskin has taken a look at your
patch, I'll add some comments on that thread.

-- 
David Gibson			| For every complex problem there is a
david AT gibson.dropbear.id.au	| solution which is simple, neat and
				| wrong.
http://www.ozlabs.org/people/dgibson
