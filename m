From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net 0/2] couple of sctp fixes for 0ca50d12fe46
Date: Thu, 03 Sep 2015 10:37:47 -0400
Message-ID: <55E85B3B.6010607@gmail.com>
References: <cover.1441220305.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:33646 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753756AbbICOh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 10:37:56 -0400
In-Reply-To: <cover.1441220305.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2015 03:20 PM, Marcelo Ricardo Leitner wrote:
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

For the series

Acked-by: Vlad Yasevich <vyasevich@gmail.com>

-vlad
