From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: take PMTU from tunnel UDP socket
Date: Tue, 08 Apr 2014 13:09:11 -0400 (EDT)
Message-ID: <20140408.130911.407626440185112494.davem@davemloft.net>
References: <CAP6LPsB4gAvJ9OaM-Jb5WuVSvnrD6ba2QaMtzEtjt2nUEPr-Cw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmgenp@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756240AbaDHRJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:09:12 -0400
In-Reply-To: <CAP6LPsB4gAvJ9OaM-Jb5WuVSvnrD6ba2QaMtzEtjt2nUEPr-Cw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Petukhov <dmgenp@gmail.com>
Date: Tue, 8 Apr 2014 21:15:50 +0600

> When l2tp driver tries to get PMTU for the tunnel destination, it uses
> the pointer to struct sock that represents PPPoX socket, while it
> should use the pointer that represents UDP socket of the tunnel.
> 
> Signed-off-by: Dmitry Petukhov <dmgenp@gmail.com>
> ---
>  net/l2tp/l2tp_ppp.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
> index d276e2d..950909f 100644
> --- a/net/l2tp/l2tp_ppp.c
> +++ b/net/l2tp/l2tp_ppp.c
> @@ -753,9 +753,9 @@ static int pppol2tp_connect(struct socket *sock,
> struct sockaddr *uservaddr,

Your patch has been corrupted by your email client, please fix this up
and resubmit.
