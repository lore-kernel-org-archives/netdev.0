From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2.6 NET] Fix ifmap alignment issues over rtnetlink
Date: Wed, 22 Sep 2004 02:03:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922000325.GN566@postel.suug.ch>
References: <20040921224127.GM566@postel.suug.ch> <20040921165733.3e0d31d8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040921165733.3e0d31d8.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <20040921165733.3e0d31d8.davem@davemloft.net> 2004-09-21 16:57
> On Wed, 22 Sep 2004 00:41:27 +0200
> Thomas Graf <tgraf@suug.ch> wrote:
> 
> > +		k_map.mem_start = (unsigned long) u_map->mem_start;
> > +		k_map.mem_end = (unsigned long) u_map->mem_end;
> > +		k_map.base_addr = (unsigned short) u_map->base_addr;
> > +		k_map.irq = (unsigned char) u_map->irq;
> > +		k_map.dma = (unsigned char) u_map->dma;
> > +		k_map.port = (unsigned char) u_map->port;
> 
> Please cast to the actual types that struct ifmap uses,
> otherwise the change is OK.

It is or am I missing something?
