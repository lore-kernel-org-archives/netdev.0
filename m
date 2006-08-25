From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH] bridge-netfilter: don't overwrite memory outside of skb
Date: Fri, 25 Aug 2006 15:08:24 -0700
Message-ID: <20060825220824.GB26692@kroah.com>
References: <20060821135110.1114298d@localhost.localdomain> <20060821.150238.88482205.davem@davemloft.net> <20060822161628.2d69cf76@localhost.localdomain> <20060822171928.7ed34b86@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:60322 "EHLO mx2.suse.de")
	by vger.kernel.org with ESMTP id S1422839AbWHYWIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 18:08:38 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060822171928.7ed34b86@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 22, 2006 at 05:19:28PM -0700, Stephen Hemminger wrote:
> The bridge netfilter code needs to check for space at the
> front of the skb before overwriting; otherwise if skb from
> device doesn't have headroom, then it will cause random
> memory corruption.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

Queued to -stable, thanks.

greg k-h
