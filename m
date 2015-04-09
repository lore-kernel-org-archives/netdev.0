From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next 2/5] selinux/nlmsg: add RTM_GETNSID
Date: Thu, 9 Apr 2015 07:10:59 -0400
Message-ID: <CAHC9VhSp_0v+Qd3epkT4rVrP3iqS7A+vhq1TWPN6b76jk1Wpdw@mail.gmail.com>
References: <1428511002-22329-1-git-send-email-nicolas.dichtel@6wind.com>
	<1428511002-22329-3-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1428511002-22329-3-git-send-email-nicolas.dichtel@6wind.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 8, 2015 at 12:36 PM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> This new command is missing.
>
> Fixes: 9a9634545c70 ("netns: notify netns id events")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  security/selinux/nlmsgtab.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
> index 91228a730801..c8cee0766b60 100644
> --- a/security/selinux/nlmsgtab.c
> +++ b/security/selinux/nlmsgtab.c
> @@ -74,6 +74,7 @@ static struct nlmsg_perm nlmsg_route_perms[] =
>         { RTM_DELMDB,           NETLINK_ROUTE_SOCKET__NLMSG_WRITE  },
>         { RTM_GETMDB,           NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>         { RTM_NEWNSID,          NETLINK_ROUTE_SOCKET__NLMSG_WRITE },
> +       { RTM_DELNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>         { RTM_GETNSID,          NETLINK_ROUTE_SOCKET__NLMSG_READ  },
>  };

Can you elaborate a bit on the RTM_DELNSID type?  Based only on the
name I wonder if it should be treated as a "write" and not a "read"
operation.

-- 
paul moore
www.paul-moore.com
