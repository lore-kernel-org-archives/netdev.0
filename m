From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next v2 4/4] bridge: vlan: move back vlan_flush
Date: Tue, 13 Oct 2015 10:21:01 +0300
Message-ID: <20151013072101.GE28618@colbert.mtl.com>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
 <1444679225-7354-5-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <shm@cumulusnetworks.com>,
	<roopa@cumulusnetworks.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	"Nikolay Aleksandrov" <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0087.outbound.protection.outlook.com ([157.55.234.87]:53632
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751880AbbJMHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 03:21:09 -0400
Content-Disposition: inline
In-Reply-To: <1444679225-7354-5-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 10:47:05PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>Ido Schimmel reported a problem with switchdev devices because of the
>order change of del_nbp operations, more specifically the move of
>nbp_vlan_flush() which deletes all vlans and frees vlgrp after the
>rx_handler has been unregistered. So in order to fix this move
>vlan_flush back where it was and make it destroy the rhtable after
>NULLing vlgrp and waiting a grace period to make sure noone can see it.
>
>Reported-by: Ido Schimmel <idosch@mellanox.com>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>

Thanks Nikolay!
