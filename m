From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] net/bridge: Add 'hairpin' port forwarding mode
Date: Thu, 13 Aug 2009 11:07:44 -0700
Message-ID: <20090813110744.09465f76@nehalam>
References: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"kaber@trash.net" <kaber@trash.net>, Arnd Bergmann <arnd@arndb.de>,
	"Dickson, Mike (ISS Software)" <mike.dickson@hp.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"bridge@osdl.org" <bridge@osdl.org>
To: "Fischer, Anna" <anna.fischer@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:35989 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752115AbZHMSIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 14:08:11 -0400
In-Reply-To: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index eb404dc..e486f1f 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -256,6 +256,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
>  	p->path_cost = port_cost(dev);
>  	p->priority = 0x8000 >> BR_PORT_BITS;
>  	p->port_no = index;
> +	p->flags = 0;
>  	br_init_port(p);
>  	p->state = BR_STATE_DISABLED;
>  	br_stp_port_timer_init(p);

Minor nit. this is unnecessary since the structure is allocated with kzalloc.
