From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [patch net-next 12/15] ipv4: fib: Notify about nexthop status
 changes
Date: Wed, 8 Feb 2017 11:05:54 -0700
Message-ID: <a21e02bf-e146-6a02-d1cc-229be629dcb0@cumulusnetworks.com>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
 <1486549002-2056-13-git-send-email-jiri@resnulli.us>
 <20170208145600.GA48568@C02RW35GFVH8.dhcp.broadcom.net>
 <20170208153226.GA24185@splinter.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
        davem@davemloft.net, eladr@mellanox.com, mlxsw@mellanox.com,
        Roopa Prabhu <roopa@cumulusnetworks.com>
To: Ido Schimmel <idosch@mellanox.com>,
        Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35905 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750940AbdBHSLT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:11:19 -0500
Received: by mail-pg0-f43.google.com with SMTP id v184so50831796pgv.3
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 10:11:19 -0800 (PST)
In-Reply-To: <20170208153226.GA24185@splinter.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/8/17 8:32 AM, Ido Schimmel wrote:
> In the case of multipath routes, if some of the nexthops can be
> reflected, then we do so, but periodically ask the kernel to try and
> resolve the others. Otherwise, these nexthops will never be resolved, as
> the kernel doesn't see the packets hitting the multipath route and
> therefore lacks the motivation to resolve its nexthops.

It should get the motivation once the neigh entry is cleaned up. That
can take a long time based on gc settings, but it can also happen from
the remote side if it sends an arp message.
