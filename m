From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 0/2] switchdev: unify naming prefix
Date: Wed, 15 Apr 2015 14:42:12 -0400 (EDT)
Message-ID: <20150415.144212.1655997639652635225.davem@davemloft.net>
References: <1428960304-11497-1-git-send-email-jiri@resnulli.us>
	<20150415175455.GB26741@gospo.home.greyhouse.net>
	<20150415183815.GC2026@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gospo@cumulusnetworks.com, netdev@vger.kernel.org,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, f.fainelli@gmail.com,
	sridhar.samudrala@intel.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51538 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbbDOSmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 14:42:16 -0400
In-Reply-To: <20150415183815.GC2026@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 15 Apr 2015 20:38:15 +0200

> Wed, Apr 15, 2015 at 07:54:56PM CEST, gospo@cumulusnetworks.com wrote:
>>On Mon, Apr 13, 2015 at 11:25:02PM +0200, Jiri Pirko wrote:
>>> Turned out that "switchdev" sticks. So just unify all releated terms to
>>> use this prefix.
>>> 
>>> Jiri Pirko (2):
>>>   switchdev: s/netdev_switch_/switchdev_/ and
>>>     s/NETDEV_SWITCH_/SWITCHDEV_/
>>>   switchdev: s/swdev_/switchdev_/
>>> 
>>>  drivers/net/bonding/bond_main.c      |   4 +-
>>>  drivers/net/ethernet/rocker/rocker.c |  47 +++++-----
>>>  drivers/net/team/team.c              |   4 +-
>>>  include/linux/netdevice.h            |   2 +-
>>>  include/net/switchdev.h              | 140 ++++++++++++++--------------
>>>  net/bridge/br.c                      |  22 ++---
>>>  net/bridge/br_netlink.c              |   6 +-
>>>  net/bridge/br_stp.c                  |   2 +-
>>>  net/core/net-sysfs.c                 |   2 +-
>>>  net/core/rtnetlink.c                 |   2 +-
>>>  net/dsa/slave.c                      |   8 +-
>>>  net/ipv4/fib_trie.c                  |  40 ++++----
>>>  net/switchdev/switchdev.c            | 174 +++++++++++++++++------------------
>>>  13 files changed, 224 insertions(+), 229 deletions(-)
>>
>>Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>
>>
> 
> Unfortunatelly, this patchset did not make it into this net-next. Will
> resubmit with the acks once the merge-window closes.

Scott said he would integrate the name change into his series, since it's
now deferred as well.
