From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 0/3] tcp: allow to repair a tcp connections in
 closing states
Date: Mon, 24 Mar 2014 19:29:32 -0400 (EDT)
Message-ID: <20140324.192932.881876462361283961.davem@davemloft.net>
References: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, criu@openvz.org,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, edumazet@google.com,
	xemul@parallels.com, gorcunov@openvz.org
To: avagin@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbaCXX3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:29:36 -0400
In-Reply-To: <1395408781-8145-1-git-send-email-avagin@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrey Vagin <avagin@openvz.org>
Date: Fri, 21 Mar 2014 17:32:58 +0400

> Currently connections only in the TCP_ESTABLISHED state can be dumped and
> restored. This series allows to restore connections in the FIN_WAIT_1,
> FIN_WAIT_2, LAST_ACK, CLOSE_WAIT or CLOSING states.
> 
> For restoring closing states we need an ability to restore a fin packet
> in a queue. In this series I suggest to use the interface of control
> messages for that.

I see no real value in this unless you tackle TIME_WAIT as well, and
that's going to add so much code.
