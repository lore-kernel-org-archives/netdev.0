From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] netlink: fix overrun in attribute iteration
Date: Thu, 11 Sep 2008 16:52:43 -0700
Message-ID: <20080911165243.125a74cc.akpm@linux-foundation.org>
References: <20080911205933.GA20032@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch,
	penberg@cs.helsinki.fi, mingo@elte.hu, viro@zeniv.linux.org.uk,
	linux-kernel@vger.kernel.org
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51671 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751810AbYIKXxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 19:53:17 -0400
In-Reply-To: <20080911205933.GA20032@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Sep 2008 22:59:33 +0200
Vegard Nossum <vegard.nossum@gmail.com> wrote:

>   #include <stdio.h>
> 
>   main(void)
>   {
>           printf("%d\n", -1 >= sizeof(int));
>   }
> 

akpm:/home/akpm> gcc -W t.c
t.c: In function 'main':
t.c:5: warning: comparison between signed and unsigned

Make of that what you will :)
