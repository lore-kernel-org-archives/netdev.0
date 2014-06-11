From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipip, sit: fix ipv4_{update_pmtu,redirect} calls
Date: Tue, 10 Jun 2014 23:36:24 -0700 (PDT)
Message-ID: <20140610.233624.23993271628864053.davem@davemloft.net>
References: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606231921.2ff39106ac54216fd9170fae@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Fri, 6 Jun 2014 23:19:21 +0400

> ipv4_{update_pmtu,redirect} were called with tunnel's ifindex (t->dev is a 
> tunnel netdevice). It caused wrong route lookup and failure of pmtu update or 
> redirect. We should use the same ifindex that we use in ip_route_output_* in 
> *tunnel_xmit code. It is t->parms.link .
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Applied and queued up for -stable, thanks.
