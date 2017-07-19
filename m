From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [patch net-next 10/17] ipv6: fib: Add offload indication to
 routes
Date: Wed, 19 Jul 2017 18:49:20 +0300
Message-ID: <20170719154920.GA6078@splinter>
References: <20170719070232.28457-1-jiri@resnulli.us>
 <20170719070232.28457-11-jiri@resnulli.us>
 <21bdef55-9cd2-8a17-9eaa-a10cfc6ef4d4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        nikolay@cumulusnetworks.com, kafai@fb.com,
        hannes@stressinduktion.org, yoshfuji@linux-ipv6.org,
        edumazet@google.com, yanhaishuang@cmss.chinamobile.com
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10079.outbound.protection.outlook.com ([40.107.1.79]:26656
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755448AbdGSPt1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 11:49:27 -0400
Content-Disposition: inline
In-Reply-To: <21bdef55-9cd2-8a17-9eaa-a10cfc6ef4d4@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 19, 2017 at 09:27:30AM -0600, David Ahern wrote:
> On 7/19/17 1:02 AM, Jiri Pirko wrote:
> > Allow user space applications to see which routes are offloaded and
> > which aren't by setting the RTNH_F_OFFLOAD flag when dumping them.
> > 
> > To be consistent with IPv4, a multipath route is marked as offloaded if
> > one of its nexthops is offloaded. Individual nexthops aren't marked with
> > the 'offload' flag.
> 
> It is more user friendly to report the offload per nexthop especially
> given the implications. There are already flags per nexthop and those
> flags are pushed to userspace so not an API change at all.

I thought about it, but then just decided to be consistent with IPv4.

I can send a follow-up patchset that aligns both families to the
behavior you requested. Need to teach iproute2 to look for
RTNH_F_OFFLOAD in rtnh_flags as well.
