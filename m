From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sun, 15 Jan 2017 09:51:03 +0800
Message-ID: <1484445063.4555.8.camel@163.com>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
         <20170114162453.GB1072@lunn.ch>
         <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-11.163.com ([220.181.12.11]:39604 "EHLO m12-11.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750743AbdAOBvX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Jan 2017 20:51:23 -0500
In-Reply-To: <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 六, 2017-01-14 at 10:35 -0800, Florian Fainelli wrote:
> On 01/14/2017 08:24 AM, Andrew Lunn wrote:
> > 
> > On Sat, Jan 14, 2017 at 10:46:31AM +0800, yuan linyu wrote:
> > > 
> > > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
> > > 
> > > if phy device have register(s) configuration problem,
> > > user can use this attribute to diagnose.
> > > this feature need phy driver maintainer implement.
> > what is wrong with mii-tool -vv ?
> Agreed, and without an actual user of this API (ethtool?), nor a PHY
> driver implementing it, we cannot quite see how you want to make use of
> this.
I hope user/developer can read this attribute file "regs" to do
a full check of all registers value, and they can write any register
inside PHY through this file.

I think mii-tool or ethtool can't do it currently.
> 
> Thank you
