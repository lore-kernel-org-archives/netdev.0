From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sun, 15 Jan 2017 18:21:50 +0100
Message-ID: <20170115172150.GC5643@lunn.ch>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
 <20170114162453.GB1072@lunn.ch>
 <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
 <1484445063.4555.8.camel@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: yuan linyu <cugyly@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:60618 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbdAORWA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 12:22:00 -0500
Content-Disposition: inline
In-Reply-To: <1484445063.4555.8.camel@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 15, 2017 at 09:51:03AM +0800, yuan linyu wrote:
> On ???, 2017-01-14 at 10:35 -0800, Florian Fainelli wrote:
> > On 01/14/2017 08:24 AM, Andrew Lunn wrote:
> > > 
> > > On Sat, Jan 14, 2017 at 10:46:31AM +0800, yuan linyu wrote:
> > > > 
> > > > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > > 
> > > > if phy device have register(s) configuration problem,
> > > > user can use this attribute to diagnose.
> > > > this feature need phy driver maintainer implement.
> > > what is wrong with mii-tool -vv ?
> > Agreed, and without an actual user of this API (ethtool?), nor a PHY
> > driver implementing it, we cannot quite see how you want to make use of
> > this.
> I hope user/developer can read this attribute file "regs" to do
> a full check of all registers value, and they can write any register
> inside PHY through this file.

Since this is intended for debug, it should not be sysfs, but debugfs.

However, in general, Linux does not allow user space to peek and poke
device registers. Can you point me at examples where i can do the same
to my GPU? SATA controller? Ethernet controller, I2C temperature
sensor? Any device?

   Andrew
