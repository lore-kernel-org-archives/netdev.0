From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next v2 1/6] net: sched: introduce a TRAP control
 action
Date: Tue, 6 Jun 2017 14:22:08 +0200
Message-ID: <20170606122208.GF18198@lunn.ch>
References: <20170606121207.2921-1-jiri@resnulli.us>
 <20170606121207.2921-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, edumazet@google.com,
        alexander.h.duyck@intel.com, stephen@networkplumber.org,
        daniel@iogearbox.net, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37816 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751384AbdFFMWT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 08:22:19 -0400
Content-Disposition: inline
In-Reply-To: <20170606121207.2921-2-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 06, 2017 at 02:12:02PM +0200, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> There is need to instruct the HW offloaded path to push certain matched
> packets to cpu/kernel for further analysis. So this patch introduces a
> new TRAP control action to TC.
> 
> For kernel datapath, this action does not make much sense. So with the
> same logic as in HW, new TRAP behaves similar to STOLEN. The skb is just
> dropped in the datapath (and virtually ejected to an upper level, which
> does not exist in case of kernel).
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> Reviewed-by: Yotam Gigi <yotamg@mellanox.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
