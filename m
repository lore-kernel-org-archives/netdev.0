From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net 5/7] gtp: Initialize 64-bit per-cpu stats correctly
Date: Wed, 2 Aug 2017 12:46:10 +0200
Message-ID: <20170802104610.GA2566@salvia>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
 <20170801191113.8754-6-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
        Harald Welte <laforge@gnumonks.org>,
        "open list:GTP (GPRS Tunneling Protocol)"
        <osmocom-net-gprs@lists.osmocom.org>,
        open list <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170801191113.8754-6-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 12:11:10PM -0700, Florian Fainelli wrote:
> On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
> lockdep splat indicating this seqcount is not correctly initialized, fix
> that by using netdev_alloc_pcpu_stats() instead of an open coded
> allocation.
> 
> Fixes: 459aa660eb1d ("gtp: add initial driver for datapath of GPRS Tunneling Protocol (GTP-U)")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

Thanks!
