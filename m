From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [patch net-next 4/4] mlxsw: spectrum: Add packet sample
 offloading support
Date: Sun, 22 Jan 2017 14:04:56 +0200
Message-ID: <20170122120456.GA20356@splinter.mtl.com>
References: <1485085487-2652-1-git-send-email-jiri@resnulli.us>
 <1485085487-2652-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, eladr@mellanox.com, nogahf@mellanox.com,
        ogerlitz@mellanox.com, jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:60366 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750735AbdAVMFl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Jan 2017 07:05:41 -0500
Content-Disposition: inline
In-Reply-To: <1485085487-2652-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 22, 2017 at 12:44:47PM +0100, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Using the MPSC register, add the functions that configure port-based
> packet sampling in hardware and the necessary datatypes in the
> mlxsw_sp_port struct. In addition, add the necessary trap for sampled
> packets and integrate with matchall offloading to allow offloading of the
> sample tc action.
> 
> The current offload support is for the tc command:
> 
> tc filter add dev <DEV> parent ffff: \
> 	  matchall skip_sw \
> 	  action sample rate <RATE> group <GROUP> [trunc <SIZE>]
> 
> Where only ingress qdiscs are supported, and only a combination of
> matchall classifier and sample action will lead to activating hardware
> packet sampling.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Reviewed-by: Ido Schimmel <idosch@mellanox.com>
