From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH net-next V1 1/9] IB/ipoib: Add support for clones /
 multiple childs on the same partition
Date: Thu, 19 Jul 2012 00:24:58 +0300
Message-ID: <CAJZOPZ+v291u5fSxJBu6q86LSpGAUgxLkhQb-ucL+g=hXba8cQ@mail.gmail.com>
References: <1342609202-32427-1-git-send-email-ogerlitz@mellanox.com>
	<1342609202-32427-2-git-send-email-ogerlitz@mellanox.com>
	<20120718.113850.305478348143779010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: roland@kernel.org, netdev@vger.kernel.org, ali@mellanox.com,
	sean.hefty@intel.com, shlomop@mellanox.com, erezsh@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:34977 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab2GRVY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 17:24:59 -0400
Received: by yenl2 with SMTP id l2so2108105yen.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 14:24:59 -0700 (PDT)
In-Reply-To: <20120718.113850.305478348143779010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 18, 2012 at 9:38 PM, David Miller <davem@davemloft.net> wrote:
> From: Or Gerlitz <ogerlitz@mellanox.com>

>> All sorts of childs are still created/deleted through sysfs, in a
>> similar manner to the way legacy child interfaces are.

> Network device instantiation of this type is the domain of
> rtnl_link_ops rather than ugly sysfs interfaces.

Didn't add any **new** sysfs interfaces in this patch. The IPoIB sysfs
entries to create child devices are there from IPoIB's day one, and
we're only extending them a tiny bit.

Or.
