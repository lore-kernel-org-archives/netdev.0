From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Mon, 8 May 2017 18:19:19 +0200
Message-ID: <20170508161919.GA22150@lunn.ch>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
 <20170506104047.GC2017@nanopsycho>
 <1494081623.3228.1.camel@sandisk.com>
 <20170507102046.GA1889@nanopsycho.orion>
 <1494256767.2591.3.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
        "leonro@mellanox.com" <leonro@mellanox.com>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ram.amrani@cavium.com" <ram.amrani@cavium.com>,
        "sagi@grimberg.me" <sagi@grimberg.me>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "hch@lst.de" <hch@lst.de>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "leon@kernel.org" <leon@kernel.org>,
        "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52966 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752552AbdEHQTc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 8 May 2017 12:19:32 -0400
Content-Disposition: inline
In-Reply-To: <1494256767.2591.3.camel@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Several companies maintain embedded Linux
> distributions and tools to build software images. These tools provide a user
> interface that allows to select what packages go into such an image.

The tools allow you to select what binary packages are placed into the
image. You can build multiple binary packages from one source package.
Desktop distributions are not likely to do this for something as small
as iproute2. But embedded distributions can easily break up iproute2
into a number of smaller packages, as you suggested, tipc, devlink,
tc, bridge, ss, etc.

Openwrt does exactly this:

https://github.com/openwrt-mirror/openwrt/blob/master/package/network/utils/iproute2/Makefile

    Andrew
