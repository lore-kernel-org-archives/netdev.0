From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4] ipv4: remove the routes on secondary promotion
Date: Tue, 22 Mar 2011 01:07:44 -0700 (PDT)
Message-ID: <20110322.010744.58436121.davem@davemloft.net>
References: <201103192213.p2JMDq9n003083@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58203
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755239Ab1CVIHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 04:07:06 -0400
In-Reply-To: <201103192213.p2JMDq9n003083@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Sun, 20 Mar 2011 00:13:52 +0200

> 	The secondary address promotion relies on fib_sync_down_addr
> to remove all routes created for the secondary addresses when
> the old primary address is deleted. It does not happen for cases
> when the primary address is also in another subnet. Fix that
> by deleting local and broadcast routes for all secondaries while
> they are on device list and by faking that all addresses from
> this subnet are to be deleted. It relies on fib_del_ifaddr being
> able to ignore the IPs from the concerned subnet while checking
> for duplication.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
