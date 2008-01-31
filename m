From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [2.6 patch] make net/802/tr.c:sysctl_tr_rif_timeout static
Date: Thu, 31 Jan 2008 13:35:58 +0300
Message-ID: <47A1A48E.2080800@openvz.org>
References: <20080130200250.GB29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:44653 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753239AbYAaKgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 05:36:09 -0500
In-Reply-To: <20080130200250.GB29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> sysctl_tr_rif_timeout can now become static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

> ---
> e5accd81b924224d40a3f38204c08cf6896ed79b 
> diff --git a/net/802/tr.c b/net/802/tr.c
> index 3f16b17..18c6647 100644
> --- a/net/802/tr.c
> +++ b/net/802/tr.c
> @@ -76,7 +76,7 @@ static DEFINE_SPINLOCK(rif_lock);
>  
>  static struct timer_list rif_timer;
>  
> -int sysctl_tr_rif_timeout = 60*10*HZ;
> +static int sysctl_tr_rif_timeout = 60*10*HZ;
>  
>  static inline unsigned long rif_hash(const unsigned char *addr)
>  {
> 
> 

