From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PROBLEM]: potential unaligned memory access in
 drivers/usb/gadget/rndis.c
Date: Thu, 12 Mar 2009 16:51:37 -0700
Message-ID: <1236901897.4036.1.camel@brick>
References: <3848726.1723791236775868071.JavaMail.root@spooler2-g27.priv.proxad.net>
	 <20090311235119.f4609775.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yann.poupet@free.fr, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.176]:14951 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbZCLXvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 19:51:41 -0400
In-Reply-To: <20090311235119.f4609775.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-03-11 at 23:51 -0700, Andrew Morton wrote:

> Maybe the below fixed this?  afacit it is queued for 2.6.30 in the
> net-next tree: 
> 
> commit 35c26c2cf6a6a2d1c48add732d8ba002bd90784c
> Author:     Harvey Harrison <harvey.harrison@gmail.com>
> AuthorDate: Sat Feb 14 22:56:56 2009 -0800
> Commit:     David S. Miller <davem@davemloft.net>
> CommitDate: Sat Feb 14 22:56:56 2009 -0800
> 
>     rndis: remove private wrapper of __constant_cpu_to_le32
>     
>     Use cpu_to_le32 directly as it handles constant folding now, replace direct
>     uses of __constant_cpu_to_{endian} as well.
>     
>     Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
>     Acked-by: David Brownell <dbrownell@users.sourceforge.net>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 

Doubtful, this patch should be a no-op, any alignment problems that existed
before will still be there.

Harvey



