From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 0/2] couple of sctp fixes for 0ca50d12fe46
Date: Thu, 3 Sep 2015 09:58:09 -0400
Message-ID: <20150903135809.GA16879@hmsreliant.think-freely.org>
References: <cover.1441220305.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vyasevich@gmail.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43530 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755758AbbICN6V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 09:58:21 -0400
Content-Disposition: inline
In-Reply-To: <cover.1441220305.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2015 at 04:20:20PM -0300, Marcelo Ricardo Leitner wrote:
> These are two fixes for sctp after my patch on 0ca50d12fe46 ("sctp: fix
> src address selection if using secondary addresses")
> 
> The first, fix a dst leak on those it decided to skip.
> 
> The second, adds the fallback on src selection that Vlad had asked
> about. Unfortunatelly a lot of ipvs setups relies on the old behavior
> and I don't see a better fix for it.
> 
> Please consider both to -stable tree.
> 
> Thanks!
> 
> Marcelo Ricardo Leitner (2):
>   sctp: fix dst leak
>   sctp: add routing output fallback
> 
>  net/sctp/protocol.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)
> 
> -- 
> 2.4.3
> 
> 

for the series
Acked-by: Neil Horman <nhorman@tuxdriver.com>
