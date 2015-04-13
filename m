From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next 0/2] switchdev: unify naming prefix
Date: Mon, 13 Apr 2015 13:50:05 -0400
Message-ID: <20150413175000.GA26741@gospo.home.greyhouse.net>
References: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:35071 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754449AbbDMRuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 13:50:16 -0400
Received: by qkhg7 with SMTP id g7so191661439qkh.2
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 10:50:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428934475-15349-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 04:14:33PM +0200, Jiri Pirko wrote:
> Turned out that "switchdev" sticks. So just unify all releated terms to
> use this prefix.
> 

Regardless of how the ordering of this patch falls out, I think this is
nice.  Good idea, Jiri.

> Jiri Pirko (2):
>   switchdev: s/netdev_switch_/switchdev_/
>   switchdev: s/swdev_/switchdev_/
> 
>  drivers/net/bonding/bond_main.c      |   4 +-
>  drivers/net/ethernet/rocker/rocker.c |  47 +++++-----
>  drivers/net/team/team.c              |   4 +-
>  include/linux/netdevice.h            |   2 +-
>  include/net/switchdev.h              | 136 +++++++++++++--------------
>  net/bridge/br.c                      |  18 ++--
>  net/bridge/br_netlink.c              |   6 +-
>  net/bridge/br_stp.c                  |   2 +-
>  net/core/net-sysfs.c                 |   2 +-
>  net/core/rtnetlink.c                 |   2 +-
>  net/dsa/slave.c                      |   8 +-
>  net/ipv4/fib_trie.c                  |  40 ++++----
>  net/switchdev/switchdev.c            | 174 +++++++++++++++++------------------
>  13 files changed, 220 insertions(+), 225 deletions(-)
> 
> -- 
> 1.9.3
> 
