From: Xiaolan Zhang <cxzhang@us.ibm.com>
Subject: Re: [Patch] kernel memory leak fix for af_unix datagram getpeersec patch
Date: Wed, 2 Aug 2006 18:21:51 -0400
Message-ID: <OFB994A805.0392D443-ON852571BE.007AA6ED-852571BE.007ADA31@us.ibm.com>
References: <20060802.151906.21953222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: catalin.marinas@gmail.com, cxzhang@watson.ibm.com,
	czhang.us@gmail.com, jmorris@namei.org,
	linux-kernel@vger.kernel.org, michal.k.k.piotrowski@gmail.com,
	netdev@vger.kernel.org, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:32459 "EHLO e3.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S932279AbWHBWV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2006 18:21:58 -0400
In-Reply-To: <20060802.151906.21953222.davem@davemloft.net>
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I see.  The build was fine under x86 and there are so many warnings that a 
-Werror probably won't work for me.

thanks,
Catherine

David Miller <davem@davemloft.net> wrote on 08/02/2006 06:19:06 PM:

> From: Xiaolan Zhang <cxzhang@us.ibm.com>
> Date: Wed, 2 Aug 2006 18:18:07 -0400
> 
> > I did test it with CONFIG_SECURITY disabled, but did not catch the 
warning 
> > -- I verified that the build completes with a valid vmlinux image. 
There 
> > are many warnings (device drivers, and others) during the build and I 
> > didn't do a grep to find which one is specific to my patch.  Next time 

> > I'll do a diff on warnings too.
> 
> Some platforms build their platform code under arch/${ARCH}/foo with
> -Werror added to CFLAGS, sparc64 is one such platform.  So the build
> did break for me.

