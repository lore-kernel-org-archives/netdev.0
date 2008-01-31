From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [2.6 patch] make nf_ct_path[] static
Date: Thu, 31 Jan 2008 13:38:31 +0300
Message-ID: <47A1A527.9040705@openvz.org>
References: <20080130200259.GE29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:45286 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763214AbYAaKim (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 05:38:42 -0500
In-Reply-To: <20080130200259.GE29368@does.not.exist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adrian Bunk wrote:
> This patch makes the needlessly global nf_ct_path[] static.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Acked-by: Pavel Emelyanov <xemul@openvz.org>

Thanks, Adrian!

> ---
> 6396fbcebe3eb61f7e6eb1a671920a515912b005 
> diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
> index 696074a..5bd38a6 100644
> --- a/net/netfilter/nf_conntrack_standalone.c
> +++ b/net/netfilter/nf_conntrack_standalone.c
> @@ -380,7 +380,7 @@ static ctl_table nf_ct_netfilter_table[] = {
>  	{ .ctl_name = 0 }
>  };
>  
> -struct ctl_path nf_ct_path[] = {
> +static struct ctl_path nf_ct_path[] = {
>  	{ .procname = "net", .ctl_name = CTL_NET, },
>  	{ }
>  };
> 
> 

