From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next v2 1/4] bridge: vlan: use proper rcu for the
 vlgrp member
Date: Tue, 13 Oct 2015 10:19:02 +0300
Message-ID: <20151013071902.GB28618@colbert.mtl.com>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
 <1444679225-7354-2-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <shm@cumulusnetworks.com>,
	<roopa@cumulusnetworks.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	"Nikolay Aleksandrov" <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0085.outbound.protection.outlook.com ([157.55.234.85]:4193
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751994AbbJMHTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 03:19:11 -0400
Content-Disposition: inline
In-Reply-To: <1444679225-7354-2-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 10:47:02PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>The bridge and port's vlgrp member is already used in RCU way, currently
>we rely on the fact that it cannot disappear while the port exists but
>that is error-prone and we might miss places with improper locking
>(either RCU or RTNL must be held to walk the vlan_list). So make it
>official and use RCU for vlgrp to catch offenders. Introduce proper vlgrp
>accessors and use them consistently throughout the code.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
