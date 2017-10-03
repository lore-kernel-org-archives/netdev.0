From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/7] mlxsw: Add support for partial
 multicast route offload
Date: Tue, 03 Oct 2017 10:07:14 -0700 (PDT)
Message-ID: <20171003.100714.851090545020567686.davem@davemloft.net>
References: <20171003075812.1540-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, f.fainelli@gmail.com, fw@strlen.de,
        gfree.wind@vip.163.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47046 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750830AbdJCRHQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:07:16 -0400
In-Reply-To: <20171003075812.1540-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  3 Oct 2017 09:58:05 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Yotam says:
> 
> Previous patchset introduced support for offloading multicast MFC routes to
> the Spectrum hardware. As described in that patchset, no partial offloading
> is supported, i.e if a route has one output interface which is not a valid
> offloadable device (e.g. pimreg device, dummy device, management NIC), the
> route is trapped to the CPU and the forwarding is done in slow-path.
> 
> Add support for partial offloading of multicast routes, by letting the
> hardware to forward the packet to all the in-hardware devices, while the
> kernel ipmr module will continue forwarding to all other interfaces.
 ...

Series applied, thanks.
