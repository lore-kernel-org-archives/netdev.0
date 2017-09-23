From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 07/12] mlxsw: spectrum: Add the multicast
 routing offloading logic
Date: Sat, 23 Sep 2017 16:41:12 +0200
Message-ID: <20170923144112.GB21228@lunn.ch>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-8-jiri@resnulli.us>
 <20170921152654.GF27589@lunn.ch>
 <a6852db1-76a2-b4f3-c558-cd4cc0a1309b@mellanox.com>
 <20170922132152.GB31634@lunn.ch>
 <a4193a32-7ba3-a13f-fa21-da247228be74@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Yotam Gigi <yotamg@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:53221 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750769AbdIWOlR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 23 Sep 2017 10:41:17 -0400
Content-Disposition: inline
In-Reply-To: <a4193a32-7ba3-a13f-fa21-da247228be74@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > So when i look at these patches, i try to make sure the general use
> > cases works, not just the plain boring Ethernet switch box use cases
> > :-)
> 
> So when doing it, we did think about multi-ASIC situations, so I think it should
> fit :)

Maybe, maybe not. DSA is multi switch. That is what the D means,
Distributed. All switches in a cluster are presented to the software
stack as a single switch.

If your multi-ASIC architecture is the same, a distributed switch,
then you don't cover the general case. If you represent it as two
switches, with frames going between switches going via CPU, then yes,
you probably cover the general case.

    Andrew
