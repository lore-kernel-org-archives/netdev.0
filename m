From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 21:44:29 +0200
Message-ID: <20170901194429.GB8122@lunn.ch>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
 <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
 <20170901132921.GV22289@lunn.ch>
 <a0b9ab3a-45d8-3371-901b-2249a26b9192@gmail.com>
 <20170901175529.GA1249@lunn.ch>
 <abc112cc-7ac5-d65f-d1b2-136cff4de92d@gmail.com>
 <20170901185012.GA8122@lunn.ch>
 <5a3fa91f-fb1f-e5ea-987d-973dee3bf8eb@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50185 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752485AbdIATod (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 15:44:33 -0400
Content-Disposition: inline
In-Reply-To: <5a3fa91f-fb1f-e5ea-987d-973dee3bf8eb@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I see what you mean, so something along the lines of just:
> 
> tc bind dev swp0p0 queue 0 master queue 16
> 
> without having to specify the master network device since it's implicit,
> I kind of like that.

Yes, that is better.

     Andrew
