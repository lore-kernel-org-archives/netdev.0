From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net] mlxsw: spectrum_router: do not drop refcnt on fib
 rule
Date: Thu, 13 Jul 2017 23:48:21 +0300
Message-ID: <20170713204821.GA4808@splinter>
References: <1499973097-14579-1-git-send-email-dsahern@gmail.com>
 <2b419d5a-8dc7-6066-4c26-699a881ce425@gmail.com>
 <20170713203358.GA8349@splinter>
 <ca0fb684-34fd-0744-1d84-829c187f6d70@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@mellanox.com, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0079.outbound.protection.outlook.com ([104.47.0.79]:63776
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752961AbdGMUs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Jul 2017 16:48:29 -0400
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

Yea, I wasn't running VRFs with the refcount patches.

Reproduced this on my system now. Thanks for the fix.
