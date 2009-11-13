From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Subject: [PATCH 3/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 12 Nov 2009 21:05:24 -0800
Message-ID: <20091112210524.3402c68e@nehalam>
References: <200911130346.nAD3kqsL001058@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <adapter_linux_open_src_team@brocade.com>
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37103 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751337AbZKMFFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2009 00:05:39 -0500
In-Reply-To: <200911130346.nAD3kqsL001058@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Nov 2009 19:46:52 -0800
Rasesh Mody <rmody@brocade.com> wrote:

> +
> +#ifndef __BIGENDIAN
> +#define bna_dma_addr64(_x) swab64((_x))
> +#else
> +#define bna_dma_addr64(_x) (_x)
> +#endif
> +

This should be cpu_to_le64 and any data with byte order
dependency should be declared leXX etc. Then sparse tool can
check for misuse of endian.


-- 
