From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH 1/3] net: drop capability from protocol definitions
Date: Wed, 4 Nov 2009 15:31:04 -0200
Message-ID: <20091104173104.GF2603@ghostprotocols.net>
References: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nhorman@redhat.com, dwalsh@redhat.com,
	davem@davemloft.net, linux-security-module@vger.kernel.org
To: Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091104163211.27133.74927.stgit@paris.rdu.redhat.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Wed, Nov 04, 2009 at 11:32:11AM -0500, Eric Paris escreveu:
> struct can_proto had a capability field which wasn't ever used.  It is dropped
> entirely.
> 
> struct inet_protosw had a capability field which can be more clearly expressed
> in the code by just checking if sock->type = SOCK_RAW.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
