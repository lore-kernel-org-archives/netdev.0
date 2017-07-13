From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] mlxsw: spectrum_router: do not drop refcnt on fib
 rule
Date: Fri, 14 Jul 2017 00:05:38 +0300
Message-ID: <20170713210538.GA20474@splinter>
References: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
 <2b419d5a-8dc7-6066-4c26-699a881ce425@gmail.com>
 <20170713203358.GA8349@splinter>
 <ca0fb684-34fd-0744-1d84-829c187f6d70@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0042.outbound.protection.outlook.com ([104.47.0.42]:14499
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752478AbdGMVFp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 17:05:45 -0400
Content-Disposition: inline
In-Reply-To: <ca0fb684-34fd-0744-1d84-829c187f6d70@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 13, 2017 at 02:39:10PM -0600, David Ahern wrote:
> On 7/13/17 2:33 PM, Ido Schimmel wrote:
> > Remains where? It's not clear to me how you concluded mlxsw is at fault.
> > My setup is running net-next with the refcount patches and I didn't
> > observe this.
> 
> Create a VRF.

BTW, this didn't show up on my dev branch as I've patches that introduce
IPv6 support where I move the rules notifications to core, after the
refcount is set to 1 and just before the netlink notification is sent.
https://github.com/idosch/linux/commit/7b17a21b1d71fc9a1969080e5fdcb90f376b73b2
