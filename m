From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC net-next] net: dsa: Provide CPU port statistics to
 master netdev
Date: Tue, 26 Apr 2016 22:13:37 +0200
Message-ID: <20160426201337.GG30107@lunn.ch>
References: <1461175101-13506-1-git-send-email-f.fainelli@gmail.com>
 <20160425214342.GB5538@lunn.ch>
 <571FC532.4060402@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46731 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751999AbcDZUNk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2016 16:13:40 -0400
Content-Disposition: inline
In-Reply-To: <571FC532.4060402@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Hi Florian
> > 
> > Interesting concept. My one concern is that by concatenating the two
> > sets of statistics, we get a name clash. I'm not sure the Marvell
> > switch statistics counters have different names to the Marvell
> > Ethernet driver statistics counters. ethtool does not care, but maybe
> > an SNMP agent using these statistics might not be too happy seeing the
> > same name twice?
> 
> That's a very good point, would you agree if we were prefixing the DSA
> CPU port statistics with some kind of name, e.g: cpu_port_<name> or
> something more compact?

Yes, that would be O.K.

It cannot be too long a prefix. The maximum length of the name is
32. The header file is unclear if there must be a NULL at the end. It
looks like the longest switch statistic we have is
RxPkts1024toMaxPktsOctets, i.e. 25 characters. So we only have 6 or 7
characters for the prefix.

	   Andrew
