From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-2.6: SYN retransmits: Add new parameter to
 retransmits_timed_out()
Date: Tue, 28 Sep 2010 13:08:46 -0700 (PDT)
Message-ID: <20100928.130846.189690989.davem@davemloft.net>
References: <1285703094.7187.3.camel@nexus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: damian@tvk.rwth-aachen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43454
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756114Ab0I1UI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 16:08:26 -0400
In-Reply-To: <1285703094.7187.3.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Date: Tue, 28 Sep 2010 21:44:54 +0200

> 
> This patch adds a syn_set parameter to the retransmits_timed_out()
> routine and updates its callers. If not set, TCP_RTO_MIN is taken
> as the calculation basis as before. If set, TCP_TIMEOUT_INIT is
> used instead, so that sysctl_syn_retries represents the actual
> amount of SYN retransmissions in case no SYNACKs are received when
> establishing a new connection.
> 
> Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

Applied, thanks Damian.
