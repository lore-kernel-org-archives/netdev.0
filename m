From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net v3 4/5] dt: cpsw: phy-handle, phy_id, and fixed-link
 are mutually exclusive
Date: Tue, 3 May 2016 11:14:01 -0500
Message-ID: <20160503161401.GA32607@rob-hp-laptop>
References: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
 <1461807767-4563-1-git-send-email-drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
	Andrew Goodbody <andrew.goodbody-nYQdZkeIoGZN8Ch2cx6nig@public.gmane.org>,
	Markus Brunner <systemprogrammierung.brunner-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Nicolas Chauvet <kwizart-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "David Rivshin (Allworx)" <drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1461807767-4563-1-git-send-email-drivshin.allworx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 27, 2016 at 09:42:47PM -0400, David Rivshin (Allworx) wrote:
> From: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>
> 
> The phy-handle, phy_id, and fixed-link properties are mutually exclusive,
> and only one need be specified. Make this clear in the binding doc.
> 
> Also mark the phy_id property as deprecated, as phy-handle should be
> used instead.
> 
> Signed-off-by: David Rivshin <drivshin-5fOYsn7Fw8lBDgjK7y7TUQ@public.gmane.org>
> ---
> 
> Changes since v2 [1]:
> - split from previous patch 2
> - marked the phy_id property as deprecated [3]
> - removed Rob Herring's Acked-by due to above change
> 
> Changes since v1 [2]:
> - Rebased (no conflicts)
> - Added Tested-by from Nicolas Chauvet
> - Added Acked-by from Rob Herring for the binding change
> 
> [1] http://patchwork.ozlabs.org/patch/613260/
> [2] http://patchwork.ozlabs.org/patch/560324/
> [3] https://lkml.org/lkml/2016/4/22/494
> 
> 
>  Documentation/devicetree/bindings/net/cpsw.txt | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
