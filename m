From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6 NET] Fix ifmap alignment issues over rtnetlink
Date: Tue, 21 Sep 2004 16:57:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921165733.3e0d31d8.davem@davemloft.net>
References: <20040921224127.GM566@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20040921224127.GM566@postel.suug.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 00:41:27 +0200
Thomas Graf <tgraf@suug.ch> wrote:

> +		k_map.mem_start = (unsigned long) u_map->mem_start;
> +		k_map.mem_end = (unsigned long) u_map->mem_end;
> +		k_map.base_addr = (unsigned short) u_map->base_addr;
> +		k_map.irq = (unsigned char) u_map->irq;
> +		k_map.dma = (unsigned char) u_map->dma;
> +		k_map.port = (unsigned char) u_map->port;

Please cast to the actual types that struct ifmap uses,
otherwise the change is OK.

Thanks for catching this.
