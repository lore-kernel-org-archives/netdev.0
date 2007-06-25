From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 15:15:14 +0200
Message-ID: <467FBFE2.7050605@trash.net>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: OBATA Noboru <noboru.obata.ar@hitachi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:38183 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbXFYNPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 09:15:17 -0400
In-Reply-To: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OBATA Noboru wrote:
> From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> 
> Make TCP_RTO_MAX a variable, and allow a user to change it via a
> new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
> then guarantee TCP retransmission to be more controllable, say,
> at least once per 10 seconds, by setting it to 10.  This is
> quite helpful on failover-capable network devices, such as an
> active-backup bonding device.  On such devices, it is desirable
> that TCP retransmits a packet shortly after the failover, which
> is what I would like to do with this patch.  Please see
> Background and Problem below for rationale in detail.


Would it make sense to do this per route?

