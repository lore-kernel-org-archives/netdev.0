From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] asm/unaligned.h doesn't work well as the very first include
Date: Sun, 27 Apr 2008 08:09:44 +0200
Message-ID: <20080427060944.GB9199@uranus.ravnborg.org>
References: <20080427051918.GO5882@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:48641 "EHLO pasmtpB.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246AbYD0GJL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Apr 2008 02:09:11 -0400
Content-Disposition: inline
In-Reply-To: <20080427051918.GO5882@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 27, 2008 at 06:19:18AM +0100, Al Viro wrote:
> Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> ---
>  net/mac80211/mesh.h      |    1 +
>  net/mac80211/mesh_hwmp.c |    1 -
>  2 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
> index 742003d..9ee3aff 100644
> --- a/net/mac80211/mesh.h
> +++ b/net/mac80211/mesh.h
> @@ -13,6 +13,7 @@
>  
>  #include <linux/types.h>
>  #include <linux/jhash.h>
> +#include <asm/unaligned.h>
>  #include "ieee80211_i.h"
>  
>  
> diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
> index 02de8f1..3df8092 100644
> --- a/net/mac80211/mesh_hwmp.c
> +++ b/net/mac80211/mesh_hwmp.c
> @@ -7,7 +7,6 @@
>   * published by the Free Software Foundation.
>   */
>  
> -#include <asm/unaligned.h>
>  #include "mesh.h"

It has been discussed that any .h file should pull
in what it needs so the other of includes does not matter.
Some do them alphabetically.

Why not fix asm-*/unaligned.h so all users now and future
are fixed in one shot?

	Sam
