From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 09:06:54 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818090654.7f44a16e.davem@redhat.com>
References: <20030818091312.GA4889@lapdog>
	<20030818041911.358c3437.davem@redhat.com>
	<1061208824.16010.2119.camel@jzny.localdomain>
	<20030818051227.4f35f2f3.davem@redhat.com>
	<20030818160422.GB1793@lapdog>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@debian.org>
In-Reply-To: <20030818160422.GB1793@lapdog>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 19:04:22 +0300
Tommi Virtanen <tv@debian.org> wrote:

> ===== net/ipv6/ndisc.c 1.22 vs edited =====
> --- 1.22/net/ipv6/ndisc.c	Tue Jun 24 02:21:28 2003
> +++ edited/net/ipv6/ndisc.c	Mon Aug 18 18:51:40 2003
 ...
> +	case NETDEV_CHANGEADDR:
> +		neigh_changeaddr(&nd_tbl, dev);
> +		rt_cache_flush(0);

Don't flush the ipv4 routing cache from ipv6 please :-)
