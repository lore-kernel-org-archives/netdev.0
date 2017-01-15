From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sun, 15 Jan 2017 18:40:52 +0800
Message-ID: <1484476852.7461.4.camel@163.com>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
         <20170114162453.GB1072@lunn.ch>
         <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
         <1484445063.4555.8.camel@163.com>
         <580590a9-d03b-2fab-efe7-173427b7c331@gmail.com>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:58247 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750824AbdAOKlW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 15 Jan 2017 05:41:22 -0500
In-Reply-To: <580590a9-d03b-2fab-efe7-173427b7c331@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 六, 2017-01-14 at 17:57 -0800, Florian Fainelli wrote:
> Le 01/14/17 à 17:51, yuan linyu a écrit :
> > 
> > I think mii-tool or ethtool can't do it currently.
> Maybe they cannot right now but they can certainly be patched to support
> that. sysfs is not an appropriate interface for what you are proposing
> here. We already have a set/get register via ethtool (-d/-D) it would
> seem natural to use this.
I think most ethernet driver implement ethtool -d to dump mac register.

> 
> Besides that, are not the current ioctl() good enough for that?
I think user/developer diagnose through simple attribute file will be easy.
