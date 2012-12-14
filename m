From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: update usage info of bridge monitor
Date: Fri, 14 Dec 2012 09:11:24 -0800
Message-ID: <20121214091124.4123e3e4@nehalam.linuxnetplumber.net>
References: <1355464772-17712-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56664 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756478Ab2LNRMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 12:12:38 -0500
In-Reply-To: <1355464772-17712-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2012 13:59:32 +0800
Cong Wang <amwang@redhat.com> wrote:

> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/bridge/monitor.c b/bridge/monitor.c
> index 44e14d8..29bb931 100644
> --- a/bridge/monitor.c
> +++ b/bridge/monitor.c
> @@ -31,7 +31,7 @@ int prefix_banner;
>  
>  static void usage(void)
>  {
> -	fprintf(stderr, "Usage: bridge monitor\n");
> +	fprintf(stderr, "Usage: bridge monitor [file | link | fdb | mdb | all]\n");
>  	exit(-1);
>  }
>  

Applied.
