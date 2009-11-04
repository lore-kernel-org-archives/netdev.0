From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 3/3] net: check kern before calling security subsystem
Date: Thu, 5 Nov 2009 08:42:39 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0911050841490.6457@tundra.namei.org>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com> <20091104163224.27133.88570.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, nhorman@redhat.com, acme@redhat.com,
	dwalsh@redhat.com, davem@davemloft.net,
	linux-security-module@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091104163224.27133.88570.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Nov 2009, Eric Paris wrote:

> -	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
> +	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
>  		return -EPERM;

> -	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
> +	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
>  		goto out_rcu_unlock;

> -	if (sock->type == SOCK_RAW && !capable(CAP_NET_RAW))
> +	if (sock->type == SOCK_RAW && !kern && !capable(CAP_NET_RAW))
>  		goto out_rcu_unlock;

Perhaps make this a static inline.


-- 
James Morris
<jmorris@namei.org>
