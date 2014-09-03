From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 1/4] ipv6: coding style - no assignment in if
 statements
Date: Wed, 03 Sep 2014 10:44:09 +0900
Message-ID: <54067269.9070200@miraclelinux.com>
References: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk> <1409685364-4327-2-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og126.obsmtp.com ([64.18.2.206]:50003 "HELO
	exprod7og126.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751904AbaICBoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 21:44:13 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so16242114pab.31
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 18:44:12 -0700 (PDT)
In-Reply-To: <1409685364-4327-2-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ian Morris wrote:
> This patch makes no changes to the logic of the ipv6 stack however
> it addresses some coding style issues by removing assignments made
> in if statements.
> 
> No change in the object output is detected by the objdiff script.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index b7a3e7b..86fc687 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -754,9 +754,8 @@ slow_path:
>   		/*
>   		 *	Allocate buffer.
>   		 */
> -
> -		if ((frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) +
> -				      hroom + troom, GFP_ATOMIC)) == NULL) {
> +		frag = alloc_skb(len + hlen + sizeof(struct frag_hdr) + hroom + troom, GFP_ATOMIC);
> +		if (frag == NULL) {

This line is too long.
Otherwise, it seems okay.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
