From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ipmr: fix possible race resulting from improper
 usage of IP_INC_STATS_BH() in preemptible context.
Date: Mon, 02 Nov 2015 15:57:48 -0500 (EST)
Message-ID: <20151102.155748.1702956348406524610.davem@davemloft.net>
References: <CAOxq_8Nd8KA8CpwVPtCr2gwDbfzsqRp586PddF7r5DSSmeHb6A@mail.gmail.com>
	<1446232356.6254.23.camel@edumazet-glaptop2.roam.corp.google.com>
	<alpine.OSX.2.00.1510301651240.81585@animac.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, fw@strlen.de, hannes@stressinduktion.org,
	netdev@vger.kernel.org, ani@anirban.org, fruggeri@arista.com
To: ani@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbKBU5v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 15:57:51 -0500
In-Reply-To: <alpine.OSX.2.00.1510301651240.81585@animac.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ani Sinha <ani@arista.com>
Date: Fri, 30 Oct 2015 16:54:31 -0700 (PDT)

> Fixes the following kernel BUG :
 ...
> Signed-off-by: Ani Sinha <ani@arista.com>

Applied and queued up for -stable, thanks.
