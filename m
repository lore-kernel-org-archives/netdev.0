From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: Re: [PATCH ethtool 2/2] Ethtool: Implements
 ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE and PHY downshift
Date: Fri, 4 Nov 2016 14:28:27 +0100
Message-ID: <20161104132827.GA11277@microsemi.com>
References: <1478255805-25823-1-git-send-email-allan.nielsen@microsemi.com>
 <1478255805-25823-3-git-send-email-allan.nielsen@microsemi.com>
 <20161104115937.GH13959@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: <netdev@vger.kernel.org>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <cphealy@gmail.com>,
        <robh@kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0057.outbound.protection.outlook.com ([104.47.37.57]:65264
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753178AbcKDN3K (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 09:29:10 -0400
Content-Disposition: inline
In-Reply-To: <20161104115937.GH13959@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/16 12:59, Andrew Lunn wrote:
> > +++ b/ethtool.8.in
> > @@ -340,6 +340,14 @@ ethtool \- query or control network driver and hardware settings
> >  .B2 tx-lpi on off
> >  .BN tx-timer
> >  .BN advertise
> > +.HP
> > +.B ethtool \-\-set\-phy\-tunable
> > +.I devname
> > +.B3 downshift on off N
> > +.HP
> 
> I don't think there is any other option which is on|off|N. The general
> pattern would be
> 
> --set-phy-tunable downshift on|off [count N]
> 
> With count being optional.
> 
> This also allows avoiding the ambiguity of what
> 
> --set-phy-tunable downshift 0
> 
> means. To me, that means downshift after 0 retries. But it actually
> seems to mean never downshift. You can then error out when somebody
> does
> 
> --set-phy-tunable downshift on count 0
> or
> --set-phy-tunable downshift off count 42
Okay, I do not have any strong feelings about the syntax here.

We could not find any other signature which had the same need, so we have been
looking for things that was "close" to...

What is being proposed is similar to "-s [ mdix auto|on|off ]".

What you request is similar to "-e|--eeprom-dump [ raw on|off ] [ offset N ]".

So, unless there are other comments, then we will change this in the next
version.

> Please also add a few sentences about what downshift is, and what N
> means. Is it tries, or retries?
Sure.

We will wait a few days to see what other comments we get.

Thanks for reviewing.

/Allan
