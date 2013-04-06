From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/3] netfilter: propagate routing and XFRM errors
Date: Sat, 6 Apr 2013 14:02:01 +0200
Message-ID: <20130406120201.GA14798@localhost>
References: <1365180072-6182-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1365180072-6182-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 05, 2013 at 06:41:09PM +0200, Patrick McHardy wrote:
> These patches fix a long standing annoyance: netfilter will return
> EPERM for all errors during rerouting or XFRM policy lookups.
> 
> These patches change {ip,ip6}_route_me_harder() and nf_xfrm_me_harder()
> to return errno codes and use NF_DROP_ERR() to propagate those back
> to userspace.

Applied, thanks Patrick!
