From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 2/4] ipv6: coding style - min to min_t conversion
Date: Wed, 03 Sep 2014 10:29:30 +0900
Message-ID: <54066EFA.7090400@miraclelinux.com>
References: <1409685364-4327-1-git-send-email-ipm@chirality.org.uk> <1409685364-4327-3-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Ian Morris <ipm@chirality.org.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og115.obsmtp.com ([64.18.2.217]:43041 "HELO
	exprod7og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754740AbaICB3e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 21:29:34 -0400
Received: by mail-pd0-f169.google.com with SMTP id y10so507882pdj.28
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 18:29:33 -0700 (PDT)
In-Reply-To: <1409685364-4327-3-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ian Morris wrote:
> This patch changes a min to min_t as per checkpatch recomendation.
> 
> No change in the object output is detected by the objdiff script.
> 
> Signed-off-by: Ian Morris <ipm@chirality.org.uk>
> ---
>   net/ipv6/addrconf.c |    7 +++++--
>   1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 509c53e..23d8493 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2320,8 +2320,11 @@ ok:
>   			else
>   				stored_lft = 0;
>   			if (!update_lft && !create && stored_lft) {
> -				const u32 minimum_lft = min(
> -					stored_lft, (u32)MIN_VALID_LIFETIME);
> +				const u32 minimum_lft = min_t(
> +							  u32,
> +							  stored_lft,
> +							  MIN_VALID_LIFETIME);
> +
>   				valid_lft = max(valid_lft, minimum_lft);
>   
>   				/* RFC4862 Section 5.5.3e:
> 

Please put 1st argument(u32) at the first line and make arguments aligned.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
