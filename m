From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 5/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 12 Nov 2009 21:07:51 -0800
Message-ID: <20091112210751.06e2d3c6@nehalam>
References: <200911130346.nAD3kquT001065@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37186 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463AbZKMFIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 00:08:02 -0500
In-Reply-To: <200911130346.nAD3kquT001065@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 19:46:52 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +
> +#define wwn_t u64
> +#define lun_t u64

No need for obfuscation, at least use a typedef.

> +
> +#define WWN_NULL	(0)

Why is NULL not good enuf

> +#define FC_SYMNAME_MAX	256	/*  max name server symbolic name size */
> +#define FC_ALPA_MAX	128
> +
> +#pragma pack(1)
> +
> +#define MAC_ADDRLEN	(6)
> +struct mac { u8 mac[MAC_ADDRLEN]; };

Cant you use ETH_ALEN instead?

-- 
