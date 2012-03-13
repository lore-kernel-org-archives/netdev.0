From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: ipv4: Standardize prefixes for message
 logging
Date: Mon, 12 Mar 2012 17:35:52 -0700
Message-ID: <1331598952.13200.43.camel@joe2Laptop>
References: <1331526971.13200.9.camel@joe2Laptop>
	 <20120311.234846.455580505379366792.davem@davemloft.net>
	 <1331571812.13200.23.camel@joe2Laptop>
	 <20120312.170558.584205292599435892.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120312.170558.584205292599435892.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-12 at 17:05 -0700, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Mon, 12 Mar 2012 10:03:32 -0700
> > Add #define pr_fmt(fmt) as appropriate.
> > Add "IPv4: ", "TCP: ", and "IPsec: " to appropriate files.
> > Standardize on "UDPLite: " for appropriate uses.
> > Some prefixes were previously "UDPLITE: " and "UDP-Lite: ".
[]
> Looks good, and applied,

OK.  I'll submit a similar change for net/ipv6 in awhile.

> but I left out this hunk:
 
> > diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
> > index 63b64c4..56d6768 100644
> > --- a/net/ipv4/ipcomp.c
> > +++ b/net/ipv4/ipcomp.c
> > @@ -13,6 +13,7 @@
> >   *   - Compression stats.
> >   *   - Adaptive compression.
> >   */
> > +
> >  #include <linux/module.h>
> >  #include <linux/err.h>
> >  #include <linux/rtnetlink.h>
> 
> As it seemed accidental, if not gratuitous.

It wasn't accidental, though I could have mentioned it
in the changelog.  Most files have a blank line between
an initial block commment and the first #include.

I just do that by habit when looking if a file could
benefit from a #define pr_fmt.

I added a similar blank line to udplite.c, but there
I also added pr_fmt.

cheers, Joe
