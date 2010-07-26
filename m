From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/qla3xxx.c: Checkpatch cleanups
Date: Sun, 25 Jul 2010 22:03:48 -0700 (PDT)
Message-ID: <20100725.220348.48497105.davem@davemloft.net>
References: <118c687d97762e235ba61733ef1610f6443ae1eb.1279848705.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, linux-driver@qlogic.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <118c687d97762e235ba61733ef1610f6443ae1eb.1279848705.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 22 Jul 2010 18:36:17 -0700

> Remove typedefs
> Indentation and spacing
> Use a temporary for a very long pointer variable
> More 80 column compatible
> Convert a switch to if/else if
> 
> Compile tested only, depends on patch "Update logging message style"
> 
> (old)
> $ scripts/checkpatch.pl -f drivers/net/qla3xxx.c | grep "^total:"
> total: 209 errors, 82 warnings, 3995 lines checked
> 
> (new)
> $ scripts/checkpatch.pl -f drivers/net/qla3xxx.c | grep "^total:"
> total: 2 errors, 0 warnings, 3970 lines checked
> 
> $ size drivers/net/qla3xxx.o.*
>    text	   data	    bss	    dec	    hex	filename
>   50413     212   13864   64489    fbe9 drivers/net/qla3xxx.o.old
>   49959	    212	  13728	  63899	   f99b	drivers/net/qla3xxx.o.new
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Also applied, thanks Joe.
