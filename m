From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 5/5] IPoIB: add support for TIPC protocol
Date: Wed, 3 Apr 2013 18:31:49 +0300
Message-ID: <515C4B65.4040600@mellanox.com>
References: <1364993010-15515-1-git-send-email-kaber@trash.net> <1364993010-15515-6-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <jon.maloy-IzeFyvvaP7pWk0Htik3J/w@public.gmane.org>, <allan.stephens-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1364993010-15515-6-git-send-email-kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/04/2013 15:43, Patrick McHardy wrote:
> [...] all TIPC needs to know about is ARP and RARP since
> it wants to always perform "path find", even if a path is already known. [...]

Not sure to follow this part... did you mean "all IPoIB  needs to know 
about is ARP or RARP", this makes
sense indeed, since for arp/rarp we want to call unicast_arp_send which 
does path_find and looks
also for the case the path isn't valid

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
