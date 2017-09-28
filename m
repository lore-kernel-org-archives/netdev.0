From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 1/7] skbuff: Add the offload_mr_fwd_mark field
Date: Thu, 28 Sep 2017 19:49:03 +0200
Message-ID: <20170928174903.GE14940@lunn.ch>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com,
        nikolay@cumulusnetworks.com, dsa@cumulusnetworks.com,
        edumazet@google.com, willemb@google.com, johannes.berg@intel.com,
        dcaratti@redhat.com, pabeni@redhat.com, daniel@iogearbox.net,
        f.fainelli@gmail.com, fw@strlen.de, gfree.wind@vip.163.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:60247 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751580AbdI1RtR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 13:49:17 -0400
Content-Disposition: inline
In-Reply-To: <20170928173415.15551-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 28, 2017 at 07:34:09PM +0200, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Similarly to the offload_fwd_mark field, the offload_mr_fwd_mark field is
> used to allow partial offloading of MFC multicast routes.

> The reason why the already existing "offload_fwd_mark" bit cannot be used
> is that a switchdev driver would want to make the distinction between a
> packet that has already gone through L2 forwarding but did not go through
> multicast forwarding, and a packet that has already gone through both L2
> and multicast forwarding.

Hi Jiri

So we are talking about l2 vs l3. So why not call this
offload_l3_fwd_mark?

Is there anything really specific to multicast here?

   Thanks
      Andrew
