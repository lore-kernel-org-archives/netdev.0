From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Thu, 10 Mar 2016 00:16:29 +0300
Message-ID: <20160309211629.GR2207@uranus.lan>
References: <20160309204158.GO2207@uranus.lan>
 <20160309.154725.1921352291794389965.davem@davemloft.net>
 <20160309205746.GQ2207@uranus.lan>
 <20160309.161038.283281065293712589.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160309.161038.283281065293712589.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2016 at 04:10:38PM -0500, David Miller wrote:
> > 
> > and here we call for NETDEV_DOWN, which then hits masq_device_event
> > and go further to conntrack code.
> 
> Yes that's where the notifier comes from, which happens with or without
> my patch.

Thanks for explanation, Dave! I'll continue on this task tomorrow
tryin to implement optimization you proposed.
