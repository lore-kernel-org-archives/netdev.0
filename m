From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [PATCH] remove unused variables in net/sunrpc/auth.c
Date: Mon, 10 Jan 2005 23:16:51 +0100
Message-ID: <20050110221651.GA29578@stusta.de>
References: <Pine.LNX.4.61.0501102239000.2987@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
        linux-net <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesper Juhl <juhl-lkml@dif.dk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0501102239000.2987@dragon.hygekrogen.localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jan 10, 2005 at 10:50:34PM +0100, Jesper Juhl wrote:
> 
> We have a few unused variables in net/sunrpc/auth.c:320:
> 
> net/sunrpc/auth.c:320: warning: unused variable `auth'
> net/sunrpc/auth.c:333: warning: unused variable `auth'
> net/sunrpc/auth.c:345: warning: unused variable `auth'
> net/sunrpc/auth.c:385: warning: unused variable `auth'
> 
> As far as I can see, the patch that caused them to become unused is this 
> one (which btw is ~36 months old) :
> http://linux.bkbits.net:8080/linux-2.6/diffs/net/sunrpc/auth.c@1.4?nav=index.html|src/|src/net|src/net/sunrpc|hist/net/sunrpc/auth.c
> 
> Here is a patch to get rid of them (compile tested only).
>...

Doesn't this break with CONFIG_SYSCTL=y?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
