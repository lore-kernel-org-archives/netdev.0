From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 12/15] ipv4: fib: Notify about nexthop status
 changes
Date: Wed, 8 Feb 2017 20:20:38 +0200
Message-ID: <20170208182038.GA14683@splinter.mtl.com>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
 <1486549002-2056-13-git-send-email-jiri@resnulli.us>
 <20170208145600.GA48568@C02RW35GFVH8.dhcp.broadcom.net>
 <20170208153226.GA24185@splinter.mtl.com>
 <a21e02bf-e146-6a02-d1cc-229be629dcb0@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andy Gospodarek <andy@greyhouse.net>,
        Jiri Pirko <jiri@resnulli.us>, <netdev@vger.kernel.org>,
        <davem@davemloft.net>, <eladr@mellanox.com>, <mlxsw@mellanox.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10047.outbound.protection.outlook.com ([40.107.1.47]:47808
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751092AbdBHSjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 8 Feb 2017 13:39:16 -0500
Content-Disposition: inline
In-Reply-To: <a21e02bf-e146-6a02-d1cc-229be629dcb0@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 08, 2017 at 11:05:54AM -0700, David Ahern wrote:
> On 2/8/17 8:32 AM, Ido Schimmel wrote:
> > In the case of multipath routes, if some of the nexthops can be
> > reflected, then we do so, but periodically ask the kernel to try and
> > resolve the others. Otherwise, these nexthops will never be resolved, as
> > the kernel doesn't see the packets hitting the multipath route and
> > therefore lacks the motivation to resolve its nexthops.
> 
> It should get the motivation once the neigh entry is cleaned up. That
> can take a long time based on gc settings, but it can also happen from
> the remote side if it sends an arp message.

And when the remote side does that and the neighbour becomes valid we no
longer try to actively resolve it.
