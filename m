From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dev: add support of flag IFF_NOPROC
Date: Fri, 04 Oct 2013 13:29:08 -0400 (EDT)
Message-ID: <20131004.132908.559388558582428910.davem@davemloft.net>
References: <20131003104627.411f5cc4@nehalam.linuxnetplumber.net>
	<20131003.150947.2179820478039260398.davem@davemloft.net>
	<524EAF64.8000801@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988Ab3JDR3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 13:29:11 -0400
In-Reply-To: <524EAF64.8000801@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 04 Oct 2013 14:07:00 +0200

> Of course optimizing /proc and /sysfs is a good option, but any
> optimizations
> will never be as fast as disabling them for some well known
> netdevices.
> 
> Note also that the memory consumption is significantly less with this
> flag:

It potentially breaks tools, it's a non-starter, sorry.
