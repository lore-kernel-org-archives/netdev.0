From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC net-next 0/8] net: dsa: Multi-queue awareness
Date: Fri, 1 Sep 2017 19:55:29 +0200
Message-ID: <20170901175529.GA1249@lunn.ch>
References: <1504138732-65383-1-git-send-email-f.fainelli@gmail.com>
 <20170901000502.GB28960@lunn.ch>
 <7d738ef5-c312-e0b3-3605-1f31fa7dc019@gmail.com>
 <20170901132921.GV22289@lunn.ch>
 <a0b9ab3a-45d8-3371-901b-2249a26b9192@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, jhs@mojatatu.com, netdev@vger.kernel.org,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        vivien.didelot@savoirfairelinux.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49937 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752143AbdIARzd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 13:55:33 -0400
Content-Disposition: inline
In-Reply-To: <a0b9ab3a-45d8-3371-901b-2249a26b9192@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian

> >> tc bind dev sw0p0 queue 0 dev eth0 queue 16

It this the eth0 i don't like here. Why not in the implementation just
use something like netdev_master_upper_dev_get('sw0p0')? Or does

tc bind dev sw0p0 queue 0 dev lo queue 16

make sense?

     Andrew
