From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: add rbnode to struct sk_buff
Date: Mon, 03 Nov 2014 16:37:48 -0500 (EST)
Message-ID: <20141103.163748.929657552226178600.davem@davemloft.net>
References: <1415031593.14083.25.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7M0--G=znvqQwy5Qmnm5po9yApcn4LjSSv8+-5c1D7RwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, wygivan@google.com
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752125AbaKCVhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 16:37:51 -0500
In-Reply-To: <CAHA+R7M0--G=znvqQwy5Qmnm5po9yApcn4LjSSv8+-5c1D7RwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 3 Nov 2014 13:34:33 -0800

> No objections, but this is hacky, rbnode is larger than ->next + ->prev,
> this means ->tstamp is always overwritten. This is why netem saves it
> to its CB. This isn't flexible.

It's the size of next+prev+tstamp.  Eric is showing exactly what is
shared with what with the struct/union layout.
