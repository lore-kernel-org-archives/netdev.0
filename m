From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v2 0/2] switchdev: unify naming prefix
Date: Wed, 15 Apr 2015 13:54:56 -0400
Message-ID: <20150415175455.GB26741@gospo.home.greyhouse.net>
References: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	roopa@cumulusnetworks.com, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33072 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755224AbbDORzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 13:55:00 -0400
Received: by ykfa3 with SMTP id a3so2917975ykf.0
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 10:54:59 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 13, 2015 at 11:25:02PM +0200, Jiri Pirko wrote:
> Turned out that "switchdev" sticks. So just unify all releated terms to
> use this prefix.
> 
> Jiri Pirko (2):
>   switchdev: s/netdev_switch_/switchdev_/ and
>     s/NETDEV_SWITCH_/SWITCHDEV_/
>   switchdev: s/swdev_/switchdev_/
> 
>  drivers/net/bonding/bond_main.c      |   4 +-
>  drivers/net/ethernet/rocker/rocker.c |  47 +++++-----
>  drivers/net/team/team.c              |   4 +-
>  include/linux/netdevice.h            |   2 +-
>  include/net/switchdev.h              | 140 ++++++++++++++--------------
>  net/bridge/br.c                      |  22 ++---
>  net/bridge/br_netlink.c              |   6 +-
>  net/bridge/br_stp.c                  |   2 +-
>  net/core/net-sysfs.c                 |   2 +-
>  net/core/rtnetlink.c                 |   2 +-
>  net/dsa/slave.c                      |   8 +-
>  net/ipv4/fib_trie.c                  |  40 ++++----
>  net/switchdev/switchdev.c            | 174 +++++++++++++++++------------------
>  13 files changed, 224 insertions(+), 229 deletions(-)

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
