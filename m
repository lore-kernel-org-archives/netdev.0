From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCHv2 net-next] xfrm: Simplify SA looking up when using
 wildcard source
Date: Tue, 1 Oct 2013 13:18:36 +0200
Message-ID: <20131001111836.GM7660@secunet.com>
References: <1380270770-19089-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36730 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752560Ab3JALSj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:18:39 -0400
Content-Disposition: inline
In-Reply-To: <1380270770-19089-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 27, 2013 at 04:32:50PM +0800, Fan Du wrote:
> __xfrm4/6_state_addr_check is a four steps check, all we need to do
> is checking whether the destination address match when looking SA
> using wildcard source address. Passing saddr from flow is worst option,
> as the checking needs to reach the fourth step while actually only
> one time checking will do the work.
> 
> So, simplify this process by only checking destination address when
> using wildcard source address for looking up SAs.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Applied to ipsec-next, thanks a lot!
