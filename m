From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: [PATCH] Change MAC without bringing interface down
Date: Mon, 18 Aug 2003 15:51:53 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818185153.GA1559@conectiva.com.br>
References: <20030818091312.GA4889@lapdog> <20030818041911.358c3437.davem@redhat.com> <1061208824.16010.2119.camel@jzny.localdomain> <20030818051227.4f35f2f3.davem@redhat.com> <20030818160422.GB1793@lapdog> <20030818090654.7f44a16e.davem@redhat.com> <20030818171144.GC1793@lapdog>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Tommi Virtanen <tv@debian.org>
Content-Disposition: inline
In-Reply-To: <20030818171144.GC1793@lapdog>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Em Mon, Aug 18, 2003 at 08:11:44PM +0300, Tommi Virtanen escreveu:
> +void neigh_changeaddr(struct neigh_table *tbl, struct net_device *dev)
> +{
> +	int i;
> +
> +	write_lock_bh(&tbl->lock);
> +
> +	for (i=0; i<=NEIGH_HASHMASK; i++) {


spaces before and after operators, please

> +struct notifier_block arp_netdev_notifier = {
> +	arp_netdev_event,
> +	NULL,
> +	0
> +};

c99 style please, that is:

struct notifier_block arp_netdev_notifier = {
	.notifier_call = arp_netdev_event,
}

> +struct notifier_block ndisc_netdev_notifier = {
> +	ndisc_netdev_event,
> +	NULL,
> +	0
> +};

ditto


Thanks,

- Arnaldo
