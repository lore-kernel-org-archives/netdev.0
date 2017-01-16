From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Mon, 16 Jan 2017 20:59:39 +0800
Message-ID: <1484571579.3374.4.camel@163.com>
References: <1484361992-30591-1-git-send-email-cugyly@163.com>
         <20170114162453.GB1072@lunn.ch>
         <da255b0c-dba6-ef35-d436-3110d8492f95@gmail.com>
         <1484445063.4555.8.camel@163.com> <20170115172150.GC5643@lunn.ch>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-12.163.com ([220.181.12.12]:37488 "EHLO m12-12.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751043AbdAPNAR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 08:00:17 -0500
In-Reply-To: <20170115172150.GC5643@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 日, 2017-01-15 at 18:21 +0100, Andrew Lunn wrote:
> On Sun, Jan 15, 2017 at 09:51:03AM +0800, yuan linyu wrote:
> > 
> > I hope user/developer can read this attribute file "regs" to do
> > a full check of all registers value, and they can write any register
> > inside PHY through this file.
> Since this is intended for debug, it should not be sysfs, but debugfs.
agree,
> However, in general, Linux does not allow user space to peek and poke
> device registers. Can you point me at examples where i can do the same
> to my GPU? SATA controller? Ethernet controller, I2C temperature
> sensor? Any device?
we can read registers of ethernet controller(memory register accessed) through devmem or ethtool
> 
>    Andrew
> 
