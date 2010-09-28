From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 18952] New: The mount of SYN retries is not
 equal to /proc/sys/net/ipv4/tcp_syn_retries
Date: Mon, 27 Sep 2010 21:52:41 -0700 (PDT)
Message-ID: <20100927.215241.246534990.davem@davemloft.net>
References: <201009271007.06705.yuri@itinteg.net>
	<20100927.011046.45906887.davem@davemloft.net>
	<1285617608.9983.30.camel@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yuri@itinteg.net, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753952Ab0I1EwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 00:52:21 -0400
In-Reply-To: <1285617608.9983.30.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Mon, 27 Sep 2010 22:00:08 +0200

> My suggestion for solving this issue:
> Introducing a third boolean parameter for retransmits_timed_out()
> indicating whether the socket is in SYN state or not. In the SYN case, 
> TCP_TIMEOUT_INIT will be used for the calculation instead of
> TCP_RTO_MIN.
> 
> Is that ok?

Sounds fine to me, please prepare a patch.

Thanks!
