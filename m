From: Jesper Juhl <juhl-lkml@dif.dk>
Subject: Re: [PATCH] remove unused variables in net/sunrpc/auth.c
Date: Tue, 11 Jan 2005 17:18:22 +0100 (CET)
Message-ID: <Pine.LNX.4.61.0501111716580.3368@dragon.hygekrogen.localhost>
References: <Pine.LNX.4.61.0501102239000.2987@dragon.hygekrogen.localhost>
 <20050110221651.GA29578@stusta.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jesper Juhl <juhl-lkml@dif.dk>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        linux-net <linux-net@vger.kernel.org>, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050110221651.GA29578@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 10 Jan 2005, Adrian Bunk wrote:

> On Mon, Jan 10, 2005 at 10:50:34PM +0100, Jesper Juhl wrote:
> > 
> > We have a few unused variables in net/sunrpc/auth.c:320:
> > 
> > net/sunrpc/auth.c:320: warning: unused variable `auth'
> > net/sunrpc/auth.c:333: warning: unused variable `auth'
> > net/sunrpc/auth.c:345: warning: unused variable `auth'
> > net/sunrpc/auth.c:385: warning: unused variable `auth'
> > 
> > As far as I can see, the patch that caused them to become unused is this 
> > one (which btw is ~36 months old) :
> > http://linux.bkbits.net:8080/linux-2.6/diffs/net/sunrpc/auth.c@1.4?nav=index.html|src/|src/net|src/net/sunrpc|hist/net/sunrpc/auth.c
> > 
> > Here is a patch to get rid of them (compile tested only).
> >...
> 
> Doesn't this break with CONFIG_SYSCTL=y?
> 
Yes, yes it does. I didn't see the CONFIG_SYSCTL connection and thus 
didn't test that :(   
Please disregard the patch, it's wrong.

-- 
Jesper Juhl
