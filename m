From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: mv643xx_eth.c merge gone bad...
Date: Mon, 31 Oct 2016 19:22:01 +0100
Message-ID: <20161031182201.GI9441@lunn.ch>
References: <20161031113349.GA8951@lunn.ch>
 <20161031.091206.236633139585216348.davem@davemloft.net>
 <20161031133538.GB9441@lunn.ch>
 <20161031.103403.293968855937308643.davem@davemloft.net>
 <efd31e03-7d18-a41e-bf7f-3c77faa6e825@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        jgunthorpe@obsidianresearch.com, jarod@redhat.com,
        netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59012 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S943237AbcJaSWK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 14:22:10 -0400
Content-Disposition: inline
In-Reply-To: <efd31e03-7d18-a41e-bf7f-3c77faa6e825@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 11:18:54AM -0700, Florian Fainelli wrote:
> On 10/31/2016 07:34 AM, David Miller wrote:
> > From: Andrew Lunn <andrew@lunn.ch>
> > Date: Mon, 31 Oct 2016 14:35:38 +0100
> > 
> >> On Mon, Oct 31, 2016 at 09:12:06AM -0400, David Miller wrote:
> >>> From: Andrew Lunn <andrew@lunn.ch>
> >>> Date: Mon, 31 Oct 2016 12:33:49 +0100
> >>>
> >>>> The merge of commit 27058af401e49d88a905df000dd26f443fcfa8ce for
> >>>> mv643xx_eth.c has gone bad:
> >>>
> >>> Sorry this should be fixed now.
> >>
> >> Hi David
> >>
> >> I think the SET_NETDEV_DEV() should be removed, which is what cause the merged conflict:
> >>
> >> http://patchwork.ozlabs.org/patch/687294/
> 
> The SET_NETDEV_DEV() is required for Jason's change to work, since he is
> doing this:
> 
> +static int get_phy_mode(struct mv643xx_eth_private *mp)
> +{
> +	struct device *dev = mp->dev->dev.parent;

Hi Florian

That requires the SET_NETDEV_DEV() which is in a different hunk of the
original patch, moving it earlier. This is the old one which is being
removed.

	Andrew
