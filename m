From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH v5 1/2] Implement IP_UNICAST_IF socket option.
Date: Tue, 07 Feb 2012 15:45:03 -0500
Message-ID: <4F318D4F.1090603@hp.com>
References: <1328643863-10404-1-git-send-email-ehoover@mines.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:38606 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756384Ab2BGUpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 15:45:06 -0500
In-Reply-To: <1328643863-10404-1-git-send-email-ehoover@mines.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/07/2012 02:44 PM, Erich E. Hoover wrote:
> 
> The IP_UNICAST_IF feature is needed by the Wine project.  This patch implements the feature by setting the outgoing interface in a similar fashion to that of IP_MULTICAST_IF.  A separate option is needed to handle this feature since the existing options do not provide all of the characteristics required by IP_UNICAST_IF, a summary is provided below.
>
> diff --git a/include/linux/in.h b/include/linux/in.h
> index 01129c0..89f6682 100644
> --- a/include/linux/in.h
> +++ b/include/linux/in.h
> @@ -86,6 +86,7 @@ struct in_addr {
>  
>  #define IP_MINTTL       21
>  #define IP_NODEFRAG     22
> +#define IP_UNICAST_IF   23

Same comment Eric had on the IPv6 one, this should come after IP_MULTICAST_ALL,
so should be 50.

-Brian
