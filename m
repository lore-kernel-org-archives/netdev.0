From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: ipmr/ip6mr: add support for keeping
 an entry age
Date: Sat, 16 Jul 2016 20:20:09 -0700 (PDT)
Message-ID: <20160716.202009.34528871894534990.davem@davemloft.net>
References: <1468508930-32720-1-git-send-email-nikolay@cumulusnetworks.com>
	<1468513707-19016-1-git-send-email-nikolay@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	shm@cumulusnetworks.com, sashok@cumulusnetworks.com,
	sharpd@cumulusnetworks.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: nikolay@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44274 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbcGQDUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jul 2016 23:20:11 -0400
In-Reply-To: <1468513707-19016-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Date: Thu, 14 Jul 2016 19:28:27 +0300

> In preparation for hardware offloading of ipmr/ip6mr we need an
> interface that allows to check (and later update) the age of entries.
> Relying on stats alone can show activity but not actual age of the entry,
> furthermore when there're tens of thousands of entries a lot of the
> hardware implementations only support "hit" bits which are cleared on
> read to denote that the entry was active and shouldn't be aged out,
> these can then be naturally translated into age timestamp and will be
> compatible with the software forwarding age. Using a lastuse entry doesn't
> affect performance because the members in that cache line are written to
> along with the age.
> Since all new users are encouraged to use ipmr via netlink, this is
> exported via the RTA_EXPIRES attribute.
> Also do a minor local variable declaration style adjustment - arrange them
> longest to shortest.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> CC: Roopa Prabhu <roopa@cumulusnetworks.com>
> CC: Shrijeet Mukherjee <shm@cumulusnetworks.com>
> CC: Satish Ashok <sashok@cumulusnetworks.com>
> CC: Donald Sharp <sharpd@cumulusnetworks.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> CC: James Morris <jmorris@namei.org>
> CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> CC: Patrick McHardy <kaber@trash.net>
> ---
> v2: Just reuse RTA_EXPIRES instead to minimize the attr size and simplify,
> others will be added when needed

Applied, thanks.
