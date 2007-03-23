From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 4/5] netem: avoid excessive requeues
Date: Fri, 23 Mar 2007 12:06:14 +0100
Message-ID: <4603B4A6.7050202@trash.net>
References: <20070321174231.890361963@linux-foundation.org>	<20070321174422.767901837@linux-foundation.org>	<4602E9CB.8030500@trash.net> <20070322.140816.104054993.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58781 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422797AbXCWLGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 07:06:39 -0400
In-Reply-To: <20070322.140816.104054993.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 22 Mar 2007 21:40:43 +0100
> 
>>Perhaps we should put this in qdisc_restart, other qdiscs have the
>>same problem.
> 
> 
> Agreed, patches welcome :)


I've tried this, but for some reason it makes TBF stay about
5% under the configured rate. Probably because of late timers,
the strange thing is that the 5% happen constantly even with
very low rates.

