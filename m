From: Ido Schimmel <idosch@mellanox.com>
Subject: Re: [PATCH net-next v2 2/4] bridge: vlan: use rcu for vlan_list
 traversal in br_fill_ifinfo
Date: Tue, 13 Oct 2015 10:19:25 +0300
Message-ID: <20151013071925.GC28618@colbert.mtl.com>
References: <1444679225-7354-1-git-send-email-razor@blackwall.org>
 <1444679225-7354-3-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <shm@cumulusnetworks.com>,
	<roopa@cumulusnetworks.com>, <stephen@networkplumber.org>,
	<bridge@lists.linux-foundation.org>, <davem@davemloft.net>,
	"Nikolay Aleksandrov" <nikolay@cumulusnetworks.com>
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0095.outbound.protection.outlook.com ([157.55.234.95]:62720
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751819AbbJMHTl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 03:19:41 -0400
Content-Disposition: inline
In-Reply-To: <1444679225-7354-3-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Oct 12, 2015 at 10:47:03PM IDT, razor@blackwall.org wrote:
>From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>
>br_fill_ifinfo is called by br_ifinfo_notify which can be called from
>many contexts with different locks held, sometimes it relies upon
>bridge's spinlock only which is a problem for the vlan code, so use
>explicitly rcu for that to avoid problems.
>
>Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
