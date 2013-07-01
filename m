From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net-next] net: sctp: get rid of SCTP_DBG_TSNS entirely
Date: Mon, 1 Jul 2013 07:33:42 -0400
Message-ID: <20130701113342.GA3168@hmsreliant.think-freely.org>
References: <1372671096-27129-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42560 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3GALdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 07:33:54 -0400
Content-Disposition: inline
In-Reply-To: <1372671096-27129-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 01, 2013 at 11:31:36AM +0200, Daniel Borkmann wrote:
> After having reworked the debugging framework, Neil and Vlad agreed to
> get rid of the leftover SCTP_DBG_TSNS code for a couple of reasons:
> 
> We can use systemtap scripts to investigate these things, we now have
> pr_debug() helpers that make life easier, and if we really need anything
> else besides those tools, we will be forced to come up with something
> better than we have there. Therefore, get rid of this ifdef debugging
> code entirely for now.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> CC: Vlad Yasevich <vyasevich@gmail.com>
> CC: Neil Horman <nhorman@tuxdriver.com>
> ---
>  On top of [PATCH net-next v4 0/2] Rework SCTP debugging framework.
> 
I think you mean on top of v4 2/2, but regardless:

Acked-by: Neil Horman <nhorman@tuxdriver.com>

I don't suppose you want to write a stap script to drop in the sourceware
examples area, in case anyone comes looking for this functionality again? :)

Thanks
Neil
