From: Ian Campbell <Ian.Campbell-mvvWK6WmYclDPfheJLI6IQ@public.gmane.org>
Subject: Re: [PATCH/RFC v2 0/13] enable SKB paged fragment lifetime
 visibility
Date: Fri, 22 Jul 2011 15:18:16 +0100
Message-ID: <1311344296.12772.80.camel@zakaz.uk.xensource.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <20110722.071349.1486529438674839197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110722.071349.1486529438674839197.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-07-22 at 15:13 +0100, David Miller wrote:
> Well, Ian, because you put all of these "struct page *" MM layer
> const changes in here I can't just apply this series once you
> get it ready enough from a networking perspective.
> 
> Why not do the const crap later, so it can be done independently
> of these changes and not be a dependency upon them?

Initially it was to help me find locations which needed consideration
(since it caused build failures) but I can flip it round now, sure.

> I know you want to pass const page structs down as far as possible,
> but that can wait for later, make the networking bits work on
> non-const pointers for now.

Will do.

Ian.

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
