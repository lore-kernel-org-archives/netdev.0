From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 2.6.22-rc5] TCP: Make TCP_RTO_MAX a variable
Date: Mon, 25 Jun 2007 09:08:44 -0700
Message-ID: <20070625090844.57a9f9e3@freepuppy.localdomain.hemminger.net>
References: <20070625.220939.132853560.noboru.obata.ar@hitachi.com>
	<467FBFE2.7050605@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: OBATA Noboru <noboru.obata.ar@hitachi.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48114 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752877AbXFYQIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 12:08:54 -0400
In-Reply-To: <467FBFE2.7050605@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 25 Jun 2007 15:15:14 +0200
Patrick McHardy <kaber@trash.net> wrote:

> OBATA Noboru wrote:
> > From: OBATA Noboru <noboru.obata.ar@hitachi.com>
> > 
> > Make TCP_RTO_MAX a variable, and allow a user to change it via a
> > new sysctl entry /proc/sys/net/ipv4/tcp_rto_max.  A user can
> > then guarantee TCP retransmission to be more controllable, say,
> > at least once per 10 seconds, by setting it to 10.  This is
> > quite helpful on failover-capable network devices, such as an
> > active-backup bonding device.  On such devices, it is desirable
> > that TCP retransmits a packet shortly after the failover, which
> > is what I would like to do with this patch.  Please see
> > Background and Problem below for rationale in detail.
> 
> 
> Would it make sense to do this per route?
> 
Both global sysctl and per route would be useful additions.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
