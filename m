From: David Miller <davem@davemloft.net>
Subject: Re: pkt_sched: fix missing check for packet overrun in
 qdisc_dump_stab()
Date: Thu, 20 Nov 2008 04:07:26 -0800 (PST)
Message-ID: <20081120.040726.38539265.davem@davemloft.net>
References: <492412B3.8050300@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35185
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754000AbYKTMHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:07:25 -0500
In-Reply-To: <492412B3.8050300@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 19 Nov 2008 14:20:51 +0100

> commit c870f95c8c5c40d2c38970246ed737b8264f0b0e
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Wed Nov 19 14:19:11 2008 +0100
> 
>     pkt_sched: fix missing check for packet overrun in qdisc_dump_stab()
>     
>     nla_nest_start() might return NULL, causing a NULL pointer dereference.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
