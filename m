From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v2 0/2] switchdev: unify naming prefix
Date: Wed, 15 Apr 2015 20:44:35 +0200
Message-ID: <20150415184435.GE2026@nanopsycho.orion>
References: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
 <20150415175455.GB26741@gospo.home.greyhouse.net>
 <20150415183815.GC2026@nanopsycho.orion>
 <20150415.144212.1655997639652635225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35338 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040AbbDOSoi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 14:44:38 -0400
Received: by widdi4 with SMTP id di4so166130004wid.0
        for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 11:44:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150415.144212.1655997639652635225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Apr 15, 2015 at 08:42:12PM CEST, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Wed, 15 Apr 2015 20:38:15 +0200
>
>> Wed, Apr 15, 2015 at 07:54:56PM CEST, gospo@cumulusnetworks.com wrote:
>>>On Mon, Apr 13, 2015 at 11:25:02PM +0200, Jiri Pirko wrote:
>>>> Turned out that "switchdev" sticks. So just unify all releated terms to
>>>> use this prefix.
>>>> 
>>>> Jiri Pirko (2):
>>>>   switchdev: s/netdev_switch_/switchdev_/ and
>>>>     s/NETDEV_SWITCH_/SWITCHDEV_/
>>>>   switchdev: s/swdev_/switchdev_/
>>>> 
>>>>  drivers/net/bonding/bond_main.c      |   4 +-
>>>>  drivers/net/ethernet/rocker/rocker.c |  47 +++++-----
>>>>  drivers/net/team/team.c              |   4 +-
>>>>  include/linux/netdevice.h            |   2 +-
>>>>  include/net/switchdev.h              | 140 ++++++++++++++--------------
>>>>  net/bridge/br.c                      |  22 ++---
>>>>  net/bridge/br_netlink.c              |   6 +-
>>>>  net/bridge/br_stp.c                  |   2 +-
>>>>  net/core/net-sysfs.c                 |   2 +-
>>>>  net/core/rtnetlink.c                 |   2 +-
>>>>  net/dsa/slave.c                      |   8 +-
>>>>  net/ipv4/fib_trie.c                  |  40 ++++----
>>>>  net/switchdev/switchdev.c            | 174 +++++++++++++++++------------------
>>>>  13 files changed, 224 insertions(+), 229 deletions(-)
>>>
>>>Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>>
>> 
>> Unfortunatelly, this patchset did not make it into this net-next. Will
>> resubmit with the acks once the merge-window closes.
>
>Scott said he would integrate the name change into his series, since it's
>now deferred as well.

Oh, ok, I missed this info.

Thanks.
