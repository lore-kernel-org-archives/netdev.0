From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 2/3] net: pass kern to net_proto_family create function
Date: Wed, 04 Nov 2009 08:54:25 -0800
Message-ID: <1257353665.10415.35.camel@Joe-Laptop.home>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
	 <20091104163217.27133.6899.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, acme@redhat.com,
	dwalsh@redhat.com, davem@davemloft.net,
	linux-security-module@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20091104163217.27133.6899.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-11-04 at 11:32 -0500, Eric Paris wrote:
> The generic __sock_create function has a kern argument which allows the
> security system to make decisions based on if a socket is being created by
> the kernel or by userspace.  This patch passes that flag to the
> net_proto_family specific create function, so it can do the same thing.
[]
> -static int pppox_create(struct net *net, struct socket *sock, int protocol)
> +static int pppox_create(struct net *net, struct socket *sock, int protocol,
> +			int kern)

etc...

Perhaps more readable as bool is_kernel?


