From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Autoneg off in TI cpsw driver
Date: Thu, 16 Feb 2017 19:57:29 +0100
Message-ID: <20170216185729.GC6096@lunn.ch>
References: <CAH9_wRMwiZA6GxdwMbOZjs-t-hnMaCRB1RSQ6nGoLOUJ+PxzRw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com
To: Sriram V <vshrirama@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:42306 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932694AbdBPS5c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 13:57:32 -0500
Content-Disposition: inline
In-Reply-To: <CAH9_wRMwiZA6GxdwMbOZjs-t-hnMaCRB1RSQ6nGoLOUJ+PxzRw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 17, 2017 at 12:01:32AM +0530, Sriram V wrote:
> Hi,
> 
> I am using a Linux Kernel 4.1 Kernel. on AM437X with dual emac configuration.
> 
> What i find is if i do the following the Link does not come up.
> 
> 1. run ethtool -s eth1 speed 10 duplex full autoneg off
> 2. remove cable
> 3. plug it in.
> 
> With the above sequence. The link does not come up. the plug in is not detected

Hi Sriram

There are a few different layers involved in this, we need to
determine which layer is unhappy.

What does ethtool show?

What does ip link show indicate?

     Andrew
