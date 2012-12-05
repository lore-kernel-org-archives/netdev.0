From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [Patch net-next] xfrm: add missing xfrm message types to selinux
 perm table
Date: Wed, 5 Dec 2012 09:14:06 +0100
Message-ID: <20121205081406.GB18940@secunet.com>
References: <1354693368-19494-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Paris <eparis@parisplace.org>,
	linux-security-module@secunet.com
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50980 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751809Ab2LEIOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 03:14:09 -0500
Content-Disposition: inline
In-Reply-To: <1354693368-19494-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ccing Eric Paris and linux-security-module.

On Wed, Dec 05, 2012 at 03:42:48PM +0800, Cong Wang wrote:
> SElinux perm table is not up-to-date.
> 
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
> index d309e7f..cc191bc 100644
> --- a/security/selinux/nlmsgtab.c
> +++ b/security/selinux/nlmsgtab.c
> @@ -93,6 +93,13 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
>  	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
>  	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
>  	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
> +	{ XFRM_MSG_REPORT,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
> +	{ XFRM_MSG_MIGRATE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
> +	{ XFRM_MSG_NEWSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
> +	{ XFRM_MSG_GETSADINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
> +	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
> +	{ XFRM_MSG_GETSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
> +	{ XFRM_MSG_MAPPING,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
>  };
>  
>  static struct nlmsg_perm nlmsg_audit_perms[] =

I'm not the maintainer of the file which this patch changes,
but I could take it into the ipsec-next tree if the selinux
people are fine with that.
