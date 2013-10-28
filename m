From: David Miller <davem@davemloft.net>
Subject: Re: Big performance loss from 3.4.63 to 3.10.13 when routing ipv4
Date: Mon, 28 Oct 2013 00:43:09 -0400 (EDT)
Message-ID: <20131028.004309.1778220551464473031.davem@davemloft.net>
References: <20131025080158.GC31491@secunet.com>
	<1382691028.7572.78.camel@edumazet-glaptop.roam.corp.google.com>
	<20131025092043.GD31491@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux@stwm.de, hannes@stressinduktion.org,
	netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750998Ab3J1EnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 00:43:11 -0400
In-Reply-To: <20131025092043.GD31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 25 Oct 2013 11:20:43 +0200

> On Fri, Oct 25, 2013 at 01:50:28AM -0700, Eric Dumazet wrote:
>> 
>> 32768 as the default seems fine to me
>> 
>> 448 bytes per dst -> thats less than 30 Mbytes of memory if we hit 65536
>> dst.
>> 
> 
> Ok, I'll add the patch below to to the ipsec tree if everyone is fine
> with that threshold.

No objections from me.
