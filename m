From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ax25: don't free pointers to statically allocated data
Date: Tue, 14 Aug 2007 17:25:56 -0700 (PDT)
Message-ID: <20070814.172556.106263629.davem@davemloft.net>
References: <20070814193038.GA5873@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20070814193038.GA5873@martell.zuzino.mipt.ru>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 14 Aug 2007 23:30:38 +0400

> commit 8d5cf596d10d740b69b5f4bbdb54b85abf75810d started to add statically
> allocated ax25_protocol's to list. However kfree() was still in place waiting
> for unsuspecting ones on module removal.
> 
> Steps to reproduce:
> 
> 	modprobe netrom
> 	rmmod netrom
> 
> P.S.: code would benefit greatly from list_add/list_del usage
> 
> kernel BUG at mm/slab.c:592!
> invalid opcode: 0000 [1] PREEMPT SMP 
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Also applied, thanks a lot.
