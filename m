From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Fix rose.ko oops on unload
Date: Wed, 03 Oct 2007 15:04:20 -0400
Message-ID: <4703E7B4.2090309@garzik.org>
References: <20071003185413.GA16242@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, davem@davemloft.net, netdev@vger.kernel.org,
	pidoux@ccr.jussieu.fr
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40766 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753662AbXJCTEf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2007 15:04:35 -0400
In-Reply-To: <20071003185413.GA16242@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Quick'n'dirty fix to 100% oops on "rmmod rose". Do you want me to
> properly unwind everything before .24?
> -----------
> Commit a3d384029aa304f8f3f5355d35f0ae274454f7cd aka
> "[AX.25]: Fix unchecked rose_add_loopback_neigh uses"
> transformed rose_loopback_neigh var into statically allocated one.
> However, on unload it will be kfree's which can't work.

I'm definitely missing something...  assuming your patch is applied, 
where is the kfree() for rose_loopback_neigh ?

	Jeff



