From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] mlxsw: spectrum_router: do not drop refcnt on fib
 rule
Date: Thu, 13 Jul 2017 23:33:58 +0300
Message-ID: <20170713203358.GA8349@splinter>
References: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
 <2b419d5a-8dc7-6066-4c26-699a881ce425@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:55441
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753263AbdGMUeG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 16:34:06 -0400
Content-Disposition: inline
In-Reply-To: <2b419d5a-8dc7-6066-4c26-699a881ce425@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 13, 2017 at 01:46:15PM -0600, David Ahern wrote:
> On 7/13/17 1:11 PM, David Ahern wrote:
> > Since mlxsw is not doing a get on the rule to increase the ref count, it
> > should not be doing a put.
> 
> upon further review, mlxsw is doing a get on the rule
> 
> Problem remains, but this is not the right fix.

Remains where? It's not clear to me how you concluded mlxsw is at fault.
My setup is running net-next with the refcount patches and I didn't
observe this.

If current trace isn't enough to pinpoint the problem, can you try to
reproduce with a KASAN enabled kernel?
