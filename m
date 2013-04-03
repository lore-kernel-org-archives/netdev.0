From: Jon Maloy <jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC 0/5] tipc: add support for TIPC over InfiniBand
Date: Wed, 3 Apr 2013 15:44:44 -0400
Message-ID: <515C86AC.1080808@ericsson.com>
References: <1364993010-15515-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Paul.Gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org" <Paul.Gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-1-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/03/2013 08:43 AM, Patrick McHardy wrote:
> The following patchset adds support for running TIPC over InfiniBand.
> The patchset consists of three parts (+ a minor fix for the ethernet media
> type):
> 
> - Preparation: removal of an the unused str2addr callback and move of the
>   bcast_addr from struct tipc_media to struct tipc_bearer. This is necessary
>   because InfiniBand doesn't have a fixed broadcast address like ethernet,
>   so it needs to be initialized with the device's broadcast address when
>   the bearer is enabled
> 
> - Introduction of a TIPC InfiniBand media type. A new media type is needed
>   to deal with the different address sizes
> 
> - Support for ETH_P_TIPC in IPoIB
> 
> The last patch is something I'd like to discuss, I realize that this diverges
> from the IPoIB specification, however the alternative would be to implement
> something which would be pretty much identical to IPoIB with the only
> difference of handling a different ethertype in the xmit function.
> 
> In fact I'd like to propose to remove all higher layer protocol knowledge
> from IPoIB except for ARP and RARP, which need special treatment. With the
> recent patch to manage neighbour entries in IPoIB itself, no further knowledge
> of higher layer protocols is required.
> 
> The patchset is based on net-next.
> 
> Comments welcome.
> 

Happy to see this initiative being taken.
It seems to me that you have grasped our intentions for 
how to add a new bearer, so I really don't have much comments,
except the one already made by Erik.

To me it looks good.

Regards
///jon



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
