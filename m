From: David Miller <davem@davemloft.net>
Subject: Re: PATCH [1/1] ipv4: Prevent malformed UFO fragments in
 ip_append_page
Date: Fri, 10 Jun 2016 17:59:03 -0700 (PDT)
Message-ID: <20160610.175903.1966273946295029255.davem@davemloft.net>
References: <6A051441C8B95A448E49718A747690B901CA76C741@gbplmail03.genband.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, xiyou.wangcong@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: steven.caron@genband.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbcFKA7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 20:59:04 -0400
In-Reply-To: <6A051441C8B95A448E49718A747690B901CA76C741@gbplmail03.genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steven Caron <steven.caron@genband.com>
Date: Fri, 10 Jun 2016 19:21:26 +0000

> As  the ip fragment offset field counts 8-byte chunks, non-final ip
> fragments must be multiples of 8 bytes of payload. Depending  on
> the mtu and ip option sizes, ip_append_page wasn't respecting this,
> notably when running NFS under UDP.
> 

All patch submissions need a proper signoff.

Please resubmit this properly.
