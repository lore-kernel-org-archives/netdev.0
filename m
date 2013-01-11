From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] tuntap: forbid calling TUNSETIFF when detached
Date: Fri, 11 Jan 2013 06:55:47 -0800
Message-ID: <1357916147.27446.3653.camel@edumazet-glaptop>
References: <1357894242-25020-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Stefan Hajnoczi <stefanha@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357894242-25020-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-11 at 16:50 +0800, Jason Wang wrote:

>  
> +	if (rcu_dereference_protected(tfile->detached, lockdep_rtnl_is_held()))
> +		return -EINVAL;
> +

Thats an open coded rtnl_dereference()

(please cleanup the whole tun.c file)
