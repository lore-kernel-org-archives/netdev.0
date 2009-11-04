From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH 2/3] net: pass kern to net_proto_family create function
Date: Wed, 4 Nov 2009 15:31:47 -0200
Message-ID: <20091104173147.GG2603@ghostprotocols.net>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com> <20091104163217.27133.6899.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@redhat.com, dwalsh@redhat.com,
	davem@davemloft.net, linux-security-module@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091104163217.27133.6899.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Nov 04, 2009 at 11:32:17AM -0500, Eric Paris escreveu:
> The generic __sock_create function has a kern argument which allows the
> security system to make decisions based on if a socket is being created by
> the kernel or by userspace.  This patch passes that flag to the
> net_proto_family specific create function, so it can do the same thing.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
