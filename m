From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] pktgen: small code cleanup
Date: Thu, 03 Apr 2014 13:35:25 -0400 (EDT)
Message-ID: <20140403.133525.1594438930436435429.davem@davemloft.net>
References: <1396427091-8230-1-git-send-email-weiyang@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fan.du@windriver.com, netdev@vger.kernel.org
To: weiyang@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45744 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752962AbaDCRdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 13:33:52 -0400
In-Reply-To: <1396427091-8230-1-git-send-email-weiyang@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <weiyang@linux.vnet.ibm.com>
Date: Wed,  2 Apr 2014 16:24:51 +0800

> Print the warning when the format is not correct.
> 
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> ---
>  net/core/pktgen.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> index fdac61c..89d33c2 100644
> --- a/net/core/pktgen.c
> +++ b/net/core/pktgen.c
> @@ -1767,7 +1767,7 @@ static ssize_t pktgen_thread_write(struct file *file,
>  	char *pg_result;
>  
>  	if (count < 1) {
> -		//      sprintf(pg_result, "Wrong command format");
> +		pr_warn("WARNING: Wrong command format in %s\n", __func__);
>  		return -EINVAL;
>  	}
>  

I don't think a kernel log message is appropriate.

The intention, as per the comment protected code, was to make this
error message show up in show_results()'s output.

I'm not applying this, sorry.
