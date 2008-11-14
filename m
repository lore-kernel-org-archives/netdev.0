From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net 1/1] Phonet: refuse to send bigger than MTU packets
Date: Fri, 14 Nov 2008 12:25:40 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811141223370.3930@wrl-59.cs.helsinki.fi>
References: <> <1226653710-27642-1-git-send-email-remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1769217365-1226658340=:3930"
Cc: Netdev <netdev@vger.kernel.org>
To: "=?utf-8?q?R=C3=A9mi=20Denis-Courmont?="
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43054 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbYKNKZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 05:25:43 -0500
In-Reply-To: <1226653710-27642-1-git-send-email-remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1769217365-1226658340=:3930
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 14 Nov 2008, Rémi Denis-Courmont wrote:

> Signed-off-by: Rémi Denis-Courmont <remi.denis-courmont@nokia.com>
> ---
>  net/phonet/af_phonet.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
> index defeb7a..7ab30f6 100644
> --- a/net/phonet/af_phonet.c
> +++ b/net/phonet/af_phonet.c
> @@ -144,8 +144,8 @@ static int pn_send(struct sk_buff *skb, struct net_device *dev,
>  	struct phonethdr *ph;
>  	int err;
>  
> -	if (skb->len + 2 > 0xffff) {
> -		/* Phonet length field would overflow */
> +	if (skb->len + 2 > 0xffff /* Phonet length field limit */ ||

It would by much better to have a well named constant there rather than 
such crazy and messy contruct with a comment.

-- 
 i.
---696208474-1769217365-1226658340=:3930--
