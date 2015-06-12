From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] net: ip_fragment: remove BRIDGE_NETFILTER mtu
 special handling
Date: Fri, 12 Jun 2015 14:29:03 +0200
Message-ID: <20150612122903.GA13790@salvia>
References: <1433503718-16514-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1433503718-16514-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 05, 2015 at 01:28:38PM +0200, Florian Westphal wrote:
> since commit d6b915e29f4adea9
> ("ip_fragment: don't forward defragmented DF packet") the largest
> fragment size is available in the IPCB.
> 
> Therefore we no longer need to care about 'encapsulation'
> overhead of stripped PPPOE/VLAN headers since ip_do_fragment
> doesn't use device mtu in such cases.

Applied, thanks Florian.
