From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: arcnet: Remove "#define bool int"
Date: Mon, 07 Jul 2014 21:35:01 -0700 (PDT)
Message-ID: <20140707.213501.964032202172502145.davem@davemloft.net>
References: <1404303121-2548-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: linux@rasmusvillemoes.dk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1404303121-2548-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Date: Wed,  2 Jul 2014 14:12:01 +0200

> The header file include/linux/arcdevice.h #defines bool to int, if
> bool is not already #defined. However, the files which use that header
> file seem to rely on that #define (unconditionally) being in effect:
> the prototypes for the functions arcrimi_reset, com20020_reset,
> com90io_reset, com90xx_reset (whose addresses are assigned to the
> hw.reset member of struct arcnet_local) use int explicitly.
> 
> Moreover, that #define is an accident waiting to happen (scenario:
> inclusion of arcdevice.h followed by inclusion of some header which
> declares function prototypes using bool). Also, #include
> <linux/types.h> must appear before #include <linux/arcdevice.h> (the
> compiler wouldn't like "typedef _Bool int").
> 
> Since none of the files using arcdevice.h declare variables of type
> "bool", the patch is actually quite simple, unlike the commit message.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>

Applied to net-next, thanks.
