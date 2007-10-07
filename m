From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [NET] IPv6 oops bisected
Date: Sun, 07 Oct 2007 09:33:10 -0400
Message-ID: <4708E016.9020300@garzik.org>
References: <4708D677.1030601@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, den@openvz.org,
	David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44038 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752347AbXJGNdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Oct 2007 09:33:18 -0400
In-Reply-To: <4708D677.1030601@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> The commit
> 
> commit 5f5dace1ce001b24fb8286e09ffd3c4d2b547e09
> Author: Denis V. Lunev <den@openvz.org>
> Date:   Thu Sep 27 12:41:26 2007 -0700
> 
>     [NET]: Various dst_ifdown routines to catch refcounting bugs
> 
> causes a 100% reproducible oops in net-2.6.24.git, in ip6_route_add().
> 
> Platform: x86-64 Fedora 7
> 
> Config and lspci attached.

And indeed, reverting this commit with 'patch -R' makes things work again.

	Jeff



