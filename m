From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [patch net-next v2 0/2] switchdev: unify naming prefix
Date: Mon, 13 Apr 2015 22:52:50 -0700
Message-ID: <552CAB32.20001@cumulusnetworks.com>
References: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sfeldma@gmail.com,
	f.fainelli@gmail.com, gospo@cumulusnetworks.com,
	sridhar.samudrala@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:32805 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465AbbDNFww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 01:52:52 -0400
Received: by qkx62 with SMTP id 62so221632011qkx.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 22:52:52 -0700 (PDT)
In-Reply-To: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/13/15, 2:25 PM, Jiri Pirko wrote:
> Turned out that "switchdev" sticks. So just unify all releated terms to
> use this prefix.

Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> Jiri Pirko (2):
>    switchdev: s/netdev_switch_/switchdev_/ and
>      s/NETDEV_SWITCH_/SWITCHDEV_/
>    switchdev: s/swdev_/switchdev_/
>
>   drivers/net/bonding/bond_main.c      |   4 +-
>   drivers/net/ethernet/rocker/rocker.c |  47 +++++-----
>   drivers/net/team/team.c              |   4 +-
>   include/linux/netdevice.h            |   2 +-
>   include/net/switchdev.h              | 140 ++++++++++++++--------------
>   net/bridge/br.c                      |  22 ++---
>   net/bridge/br_netlink.c              |   6 +-
>   net/bridge/br_stp.c                  |   2 +-
>   net/core/net-sysfs.c                 |   2 +-
>   net/core/rtnetlink.c                 |   2 +-
>   net/dsa/slave.c                      |   8 +-
>   net/ipv4/fib_trie.c                  |  40 ++++----
>   net/switchdev/switchdev.c            | 174 +++++++++++++++++------------------
>   13 files changed, 224 insertions(+), 229 deletions(-)
>
