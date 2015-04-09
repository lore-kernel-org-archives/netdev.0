From: Stephen Smalley <sds@tycho.nsa.gov>
Subject: Re: [PATCH net-next 3/5] selinux/nlmsg: add XFRM_MSG_NEWSPDINFO
Date: Thu, 09 Apr 2015 08:32:34 -0400
Message-ID: <55267162.7050304@tycho.nsa.gov>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com> <1428511002-22329-4-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	linux-kernel@vger.kernel.org, Paul Moore <paul@paul-moore.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1428511002-22329-4-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/08/2015 12:36 PM, Nicolas Dichtel wrote:
> This new command is missing.
> 
> Fixes: 880a6fab8f6b ("xfrm: configure policy hash table thresholds by netlink")
> Reported-by: Christophe Gouault <christophe.gouault@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  security/selinux/nlmsgtab.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
> index c8cee0766b60..4bc90c2aaea2 100644
> --- a/security/selinux/nlmsgtab.c
> +++ b/security/selinux/nlmsgtab.c
> @@ -103,6 +103,7 @@ static struct nlmsg_perm nlmsg_xfrm_perms[] =
>  	{ XFRM_MSG_FLUSHPOLICY,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
>  	{ XFRM_MSG_NEWAE,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
>  	{ XFRM_MSG_GETAE,	NETLINK_XFRM_SOCKET__NLMSG_READ  },
> +	{ XFRM_MSG_NEWSPDINFO,	NETLINK_XFRM_SOCKET__NLMSG_WRITE },
>  };
>  
>  static struct nlmsg_perm nlmsg_audit_perms[] =
> 

Seem to be missing a number of the other commands defined in
include/uapi/linux/xfrm.h as well, e.g. XFRM_MSG_REPORT,
XFRM_MSG_MIGRATE, XFRM_MSG_NEWSADINFO, XFRM_MSG_GETSADINFO,
XFRM_MSG_GETSPDINFO, XFRM_MSG_MAPPING.

