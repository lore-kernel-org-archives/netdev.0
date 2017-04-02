From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] phy/ethtool: Add missing SPEED_<foo> strings
Date: Sun, 02 Apr 2017 14:49:18 -0700
Message-ID: <1491169758.27353.50.camel@perches.com>
References: <7a10ea1f8a35c40fd721e15f3643c99d98cca7d8.1491168585.git.joe@perches.com>
         <20170402214031.GH5189@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0137.hostedemail.com ([216.40.44.137]:48177 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750953AbdDBVtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 2 Apr 2017 17:49:23 -0400
In-Reply-To: <20170402214031.GH5189@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2017-04-02 at 23:40 +0200, Andrew Lunn wrote:
> On Sun, Apr 02, 2017 at 02:30:06PM -0700, Joe Perches wrote:
> > Add all the currently available SPEED_<foo> strings.
[]
> > diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
[]
> > @@ -1487,6 +1487,7 @@ enum ethtool_link_mode_bit_indices {
> >   */
> >  
> >  /* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
> 
> Hi Joe
> 
> Given that this list is getting longer and longer, and the comment
> that 0..INT_MAX are legal, is it time to replace this with something
> dynamic?

Hey Andrew.

Probably not.

INT_MAX in units of millions is likely large enough for
quite awhile yet, maybe 2 decades or even more.

If you feel ambitious, and remember ethtool.h and
SPEED_<foo> uses are a public API, write something up.

cheers, Joe
