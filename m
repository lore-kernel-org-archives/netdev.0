From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/6] net: dsa: Platform data for dsa2.c
Date: Tue, 28 Jun 2016 16:17:18 +0200
Message-ID: <20160628141718.GB13778@lunn.ch>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com>
 <20160628010551.GD26597@lunn.ch>
 <CAGVrzcYzJ-NOZ-vTO_zRAVfhQ5qd=06dY9ybHfBwJHV6GtmK8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59506 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752522AbcF1OR0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 10:17:26 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcYzJ-NOZ-vTO_zRAVfhQ5qd=06dY9ybHfBwJHV6GtmK8A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 06:19:28PM -0700, Florian Fainelli wrote:
> 2016-06-27 18:05 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
> > On Mon, Jun 27, 2016 at 05:52:37PM -0700, Florian Fainelli wrote:
> >> Hi all,
> >>
> >> This patch series adds support for platform data using the new code from
> >> net/dsa/dsa2.c. The motivation behind this is that we have a bit of in tree
> >> platforms (ar7, bcm47xx, x86, others) that could be benefiting from the new
> >> dsa_register_switch() API model but do not support Device Tree, nor is there a
> >> plan to bring Device Tree to these platforms (time vs. benefits).
> >
> > Hi Florian
> >
> > Please could you convert an in tree device to actually use this.
> 
> Sure, I don't think there are going to be in tree users who need the
> dsa2_port_link information most of what we have is typically single
> chip, and so in that case, we can even re-use the existing
> dsa_platform_data.

O.K.

Less is better. When going through the old code for the earlier
re-structuring proposals, the code is not simple at times. I would
prefer not adding more complexity to dsa2 than really is needed.

       Andrew
