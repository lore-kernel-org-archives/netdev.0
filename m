From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 0/5] bonding: Patchset for rcu use in bonding
Date: Thu, 29 Aug 2013 16:28:51 +0200
Message-ID: <521F5AA3.4030105@redhat.com>
References: <521D7AA3.6030205@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52980 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753175Ab3H2OeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 10:34:01 -0400
In-Reply-To: <521D7AA3.6030205@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/2013 06:20 AM, Ding Tianhong wrote:
> Hi:
> 
> The Patch Set convert the xmit of 3ad and alb mode to use rcu lock.
> replace and add more rcu list function.
> fix a bug to protect bonding_store_xmit_hash().
> 
> I test well and no problems found till now.
> 
> Ding Tianhong (3):
> Wang Yufen (1):
> Yang Yingliang (1):
>   bonding: simplify and use RCU protection for 3ad xmit path
>   bonding: replace read_lock to rcu_read_lock for
>   bond_3ad_get_active_agg_info()
>   bonding: add rtnl lock for bonding_store_xmit_hash
>   bonding: restructure and simplify bond_for_each_slave_next()
>   bonding: use RCU protection for alb xmit path
> 
>  drivers/net/bonding/bond_3ad.c   | 35 +++++++++++++++-------------------
>  drivers/net/bonding/bond_alb.c   | 23 ++++++++++------------
>  drivers/net/bonding/bond_main.c  |  6 ++----
>  drivers/net/bonding/bond_sysfs.c |  4 ++++
>  drivers/net/bonding/bonding.h    | 41 ++++++++++++++++++++++++++++++++++++----
>  5 files changed, 68 insertions(+), 41 deletions(-)
> 
Thanks for the work, I was on vacation and travelling after my initial RCU
conversion so I got a little behind with these conversions, my idea was quite
different :-)
Anyway, I'd also appreciate some benchmarks, also some more information on what
type of testing did you run ?
I've given some preliminary comments to the patches, I'll have to think more
about them in this form.

Cheers,
 Nik
