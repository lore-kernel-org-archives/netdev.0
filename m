From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 001/001] smsc95xx: Fix hard_header_len
Date: Mon, 20 Aug 2012 02:19:04 -0700 (PDT)
Message-ID: <20120820.021904.767463153826491601.davem@davemloft.net>
References: <CAKh2mn4pK-8=OVkahSZ8VWpX9Va=qCDQUdOONK1FZ75Fbk0Mdg@mail.gmail.com>
	<1345139973.2832.3.camel@bwh-desktop.uk.solarflarecom.com>
	<CAKh2mn6fr8WjT-2h_A3zmKv3xs26AamXcpJgtK5wFPQ1BXuheg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, jimbob.betts@googlemail.com,
	netdev@vger.kernel.org
To: steve@shawell.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752803Ab2HTJTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 05:19:05 -0400
In-Reply-To: <CAKh2mn6fr8WjT-2h_A3zmKv3xs26AamXcpJgtK5wFPQ1BXuheg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve@shawell.net>
Date: Fri, 17 Aug 2012 09:35:04 +0100

>> hard_header_len is set to ETH_HLEN by alloc_etherdev() (in the
>> ether_setup() callback).  Any extra headroom you want before the
>> Ethernet header should indeed be specified in needed_headroom.
> 
> Thanks Ben, looks like this patch is doing it the right way then.
> 
> Acked-By: Steve Glendinning <steve.glendinning@shawell.net>

This patch needs to be submitted with a proper signoff.
