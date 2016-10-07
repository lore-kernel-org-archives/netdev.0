From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] devicetree: net: micrel-ksz90x1.txt: Properly explain
 skew settings
Date: Thu, 06 Oct 2016 20:49:23 -0400 (EDT)
Message-ID: <20161006.204923.1914066918563386131.davem@davemloft.net>
References: <1475676188-10639-1-git-send-email-mike.looijmans@topic.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        mark.rutland-5wv7dgnIgG8@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: mike.looijmans-Oq418RWZeHk@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475676188-10639-1-git-send-email-mike.looijmans-Oq418RWZeHk@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Mike Looijmans <mike.looijmans-Oq418RWZeHk@public.gmane.org>
Date: Wed,  5 Oct 2016 16:03:08 +0200

> The KSZ9031 skew registers contain an offset, the chip's default value
> is "neutral" which does not add any skew. Programming a 0 into a skew
> property will actually set it the maximal negative adjustment and not
> to a neutral position as one would expect.
> 
> Explain this situation in the devicetree binding documentation and list
> the settings that the chip considers neutral.
> 
> Changing the implementation to accept negative values would have been
> a better solution, but would break existing configurations.
> 
> Signed-off-by: Mike Looijmans <mike.looijmans-Oq418RWZeHk@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
