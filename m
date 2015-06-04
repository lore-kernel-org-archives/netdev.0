From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4/udp: Verify multicast group is ours in
 upd_v4_early_demux()
Date: Thu, 04 Jun 2015 00:46:58 -0700 (PDT)
Message-ID: <20150604.004658.541562931844276343.davem@davemloft.net>
References: <556CBC7E.2050005@cogentembedded.com>
	<1433366858-14317-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yurij.Plotnikov@oktetlabs.ru,
	Alexandra.Kossovsky@oktetlabs.ru, eric.dumazet@gmail.com,
	oliver.e.graff@gmail.com, sergei.shtylyov@cogentembedded.com,
	sbohrer@rgmadvisors.com
To: shawn.bohrer@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbbFDH46 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 03:56:58 -0400
In-Reply-To: <1433366858-14317-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shawn Bohrer <shawn.bohrer@gmail.com>
Date: Wed,  3 Jun 2015 16:27:38 -0500

> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> 421b3885bf6d56391297844f43fb7154a6396e12 "udp: ipv4: Add udp early
> demux" introduced a regression that allowed sockets bound to INADDR_ANY
> to receive packets from multicast groups that the socket had not joined.
> For example a socket that had joined 224.168.2.9 could also receive
> packets from 225.168.2.9 despite not having joined that group if
> ip_early_demux is enabled.
> 
> Fix this by calling ip_check_mc_rcu() in udp_v4_early_demux() to verify
> that the multicast packet is indeed ours.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> Reported-by: Yurij M. Plotnikov <Yurij.Plotnikov@oktetlabs.ru>

Applied and queued up for -stable, thanks.
