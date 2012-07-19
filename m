From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V1 1/9] IB/ipoib: Add support for clones /
 multiple childs on the same partition
Date: Thu, 19 Jul 2012 11:11:24 +0300
Message-ID: <CAJZOPZKPvwcQD4gMs_czYfgzye_i7h+2WpS4naDS6dkemkvnDQ@mail.gmail.com>
References: <1342609202-32427-2-git-send-email-ogerlitz@mellanox.com>
	<20120718.113850.305478348143779010.davem@davemloft.net>
	<CAJZOPZ+v291u5fSxJBu6q86LSpGAUgxLkhQb-ucL+g=hXba8cQ@mail.gmail.com>
	<20120718.143608.2101579052587289420.davem@davemloft.net>
	<50073484.9070501@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, roland@kernel.org,
	netdev@vger.kernel.org, ali@mellanox.com, sean.hefty@intel.com,
	shlomop@mellanox.com, erezsh@mellanox.co.il,
	Or Gerlitz <ogerlitz@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:39030 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab2GSILZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 04:11:25 -0400
Received: by yhmm54 with SMTP id m54so2479329yhm.19
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 01:11:24 -0700 (PDT)
In-Reply-To: <50073484.9070501@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 19, 2012 at 1:11 AM, John Fastabend
<john.r.fastabend@intel.com> wrote:

> [...] Also what is a "pkey"

Hi John,

pkey (pronounced PEE KEY) stands for "partition keys" where partitions are
in a way IB's vlans, so the functionality provided by IPoIB child devices
is similar to what done by Ethernet 8021q vlan devices. Dave suggests
that we use rtnl_link_ops to create these childs instead of the proprietary
sysfs which was introduced when IPoIB was merged and is described here
Documentation/infiniband/ipoib.txt


Or.
