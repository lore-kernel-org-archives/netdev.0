From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-next 3/3] geneve: Remote Checksum Offload support
Date: Tue, 8 Dec 2015 14:31:51 -0500
Message-ID: <20151208193150.GH3598@tuxdriver.com>
References: <1449599238-4094072-1-git-send-email-tom@herbertland.com>
 <1449599238-4094072-4-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, jesse@nicira.com,
	kernel-team@fb.com
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59048 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752456AbbLHTpY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 14:45:24 -0500
Content-Disposition: inline
In-Reply-To: <1449599238-4094072-4-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 08, 2015 at 10:27:18AM -0800, Tom Herbert wrote:
> Add support for remote checksum offload in both the normal and GRO
> paths. netlink command are used to enable sending of the Remote
> Checksum Data, and allow processing of it on receive. The Remote

afsO&^(*&5^a+++NO CARRIER

Did you mean to finish that sentence? ;-)
 
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Jesse is going to have to comment on your (ab)use of the reserved
fields.  I presume that an RFC would be forthcoming?

> diff --git a/include/net/geneve.h b/include/net/geneve.h
> index 3106ed6..b59ad0a 100644
> --- a/include/net/geneve.h
> +++ b/include/net/geneve.h
> @@ -8,9 +8,9 @@
>  
>  /* Geneve Header:
>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> - *  |Ver|  Opt Len  |O|C|    Rsvd.  |          Protocol Type        |
> + *  |Ver|  Opt Len  |O|C|X|  Rsvd.  |          Protocol Type        |
>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> - *  |        Virtual Network Identifier (VNI)       |    Reserved   |
> + *  |        Virtual Network Identifier (VNI)       |U| Csum start  |
>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>   *  |                    Variable Length Options                    |
>   *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

Otherwise, LGTM -- I'm really happy to see Geneve get this attention!

Acked-by: John W. Linville <linville@tuxdriver.com>

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
