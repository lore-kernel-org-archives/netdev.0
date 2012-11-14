From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4/ip_vti.c: VTI fix post-decryption forwarding
Date: Wed, 14 Nov 2012 18:54:30 -0500 (EST)
Message-ID: <20121114.185430.1119501564965650216.davem@davemloft.net>
References: <20121112221731.GA2772@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36965 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab2KNXye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 18:54:34 -0500
In-Reply-To: <20121112221731.GA2772@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Mon, 12 Nov 2012 14:17:31 -0800

> 
> 
> With the latest kernel there are two things that must be done post decryption
>  so that the packet are forwarded.
>  1. Remove the mark from the packet. This will cause the packet to not match
>  the ipsec-policy again. However doing this causes the post-decryption check to
>  fail also and the packet will get dropped. (cat /proc/net/xfrm_stat).
>  2. Remove the sp association in the skbuff so that no policy check is done on
>  the packet for VTI tunnels.
> 
> Due to #2 above we must now do a security-policy check in the vti rcv path
> prior to resetting the mark in the skbuff.
> 
> Signed-off-by: Saurabh Mohan <saurabh.mohan@vyatta.com>
> Reported-by: Ruben Herold <ruben@puettmann.net>

Please fix your email configuration so that the From: field
properly lists your full name, "Saurabh Mohan" instead of
just plain "Saurabh".

Otherwise the author of the commit will not be set properly
when I apply this.

Thanks.
