From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] XFRM: assorted IPsec fixups
Date: Tue, 11 Dec 2007 09:06:11 -0800 (PST)
Message-ID: <20071211.090611.59888503.davem@davemloft.net>
References: <20071211163019.15059.73746.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751328AbXLKRGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:06:13 -0500
In-Reply-To: <20071211163019.15059.73746.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Tue, 11 Dec 2007 11:30:19 -0500

Sorry for not pointing this out sooner:

>  * Convert 'sid' to 'secid'
>    The 'sid' name is specific to SELinux, 'secid' is the common naming
>    convention used by the kernel when refering to tokenized LSM labels
 ...
> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> index b58adc5..f75a337 100644
> --- a/include/linux/xfrm.h
> +++ b/include/linux/xfrm.h
> @@ -31,7 +31,7 @@ struct xfrm_sec_ctx {
>  	__u8	ctx_doi;
>  	__u8	ctx_alg;
>  	__u16	ctx_len;
> -	__u32	ctx_sid;
> +	__u32	ctx_secid;
>  	char	ctx_str[0];
>  };
>  

This datastructure has been exported to userspace, so we really can't
member names unless it was added only in 2.6.24 and I don't think it
was.

Correct me if I'm wrong.
