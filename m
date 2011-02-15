From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH] bnx2x: Support for managing RX indirection table
Date: Tue, 15 Feb 2011 19:39:46 +0200
Message-ID: <201102151939.47215.vladz@broadcom.com>
References: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3174 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171Ab1BORk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 12:40:29 -0500
In-Reply-To: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>  void bnx2x_set_storm_rx_mode(struct bnx2x *bp)
> @@ -4496,7 +4507,7 @@ void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
>  	bnx2x_init_eq_ring(bp);
>  	bnx2x_init_internal(bp, load_code);
>  	bnx2x_pf_init(bp);
> -	bnx2x_init_ind_table(bp);
> +	bnx2x_init_indir_table(bp);


Tom, one more thing: could u, pls., cancel this rename? ;)

thanks,
vlad

