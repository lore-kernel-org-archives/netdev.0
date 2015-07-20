From: Hariprasad S <hariprasad@chelsio.com>
Subject: RE: [PATCH net-next] cxgb4: Add debugfs entry to enable/disable
 backdoor access
Date: Mon, 20 Jul 2015 13:03:10 +0000
Message-ID: <26E3F92EC670BD429DB5CB319D773C13CD476E@nice.asicdesigners.com>
References: <1437404051-7020-1-git-send-email-hariprasad@chelsio.com>,<55ACE5ED.1030304@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Casey Leedom <leedom@chelsio.com>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3453 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756003AbbGTNDO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 09:03:14 -0400
In-Reply-To: <55ACE5ED.1030304@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


________________________________________
From: Sergei Shtylyov [sergei.shtylyov@cogentembedded.com]
Sent: Monday, July 20, 2015 5:43 PM
To: Hariprasad S; netdev@vger.kernel.org
Cc: davem@davemloft.net; Casey Leedom; Nirranjan Kirubaharan
Subject: Re: [PATCH net-next] cxgb4: Add debugfs entry to enable/disable backdoor access

Hello.

On 7/20/2015 5:54 PM, Hariprasad Shenai wrote:

> Add debugfs entry 'use_backdoor' to enable/disable backdoor access
> to read sge context. By default, we read sge context's via firmware. In
> case of FW issues, one can enable backdoor access via debugfs to dump
> sge context for debugging purpose.

> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
[...]
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> index b135d05..5b525a7 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
> @@ -2386,8 +2386,11 @@ int t4_setup_debugfs(struct adapter *adap)
>                                       EXT_MEM_SIZE_G(size));
>       }
>
> -     de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root, adap,
> -                                   &flash_debugfs_fops, adap->params.sf_size);
> +     de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root,
> +                                   adap, &flash_debugfs_fops,
> +                                   adap->params.sf_size);

>    What was the point reformatting this call?

It was done to silence checkpatch.pl warnings
