From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH net-2.6.25 4/7][ATM]: [br2864] routed support
Date: Mon, 31 Dec 2007 09:09:58 +0000
Message-ID: <20071231090957.GA28855@infradead.org>
References: <200712300107.lBU17O8i003566@cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56296 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751794AbXLaJJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 04:09:59 -0500
Content-Disposition: inline
In-Reply-To: <200712300107.lBU17O8i003566@cmf.nrl.navy.mil>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +#define BR2684_ETHERTYPE_LEN	2
> +#define BR2684_PAD_LEN		2
> +
> +#define LLC		0xaa, 0xaa, 0x03
> +#define SNAP_BRIDGED	0x00, 0x80, 0xc2
> +#define SNAP_ROUTED	0x00, 0x00, 0x00
> +#define PID_ETHERNET	0x00, 0x07
> +#define ETHERTYPE_IPV4	0x08, 0x00
> +#define ETHERTYPE_IPV6	0x86, 0xdd
> +#define PAD_BRIDGED	0x00, 0x00
> +
> +static unsigned char ethertype_ipv4[] =
> +	{ ETHERTYPE_IPV4 };
> +static unsigned char ethertype_ipv6[] =
> +	{ ETHERTYPE_IPV6 };
>  static unsigned char llc_oui_pid_pad[] =
> -    { 0xAA, 0xAA, 0x03, 0x00, 0x80, 0xC2, 0x00, 0x07, 0x00, 0x00 };
> -#define PADLEN	(2)
> +	{ LLC, SNAP_BRIDGED, PID_ETHERNET, PAD_BRIDGED };
> +static unsigned char llc_oui_ipv4[] =
> +	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV4 };
> +static unsigned char llc_oui_ipv6[] =
> +	{ LLC, SNAP_ROUTED, ETHERTYPE_IPV6 };

I think this should be in a global header.  And IIRC we already have
at least some of these somewhere as part of the general llc support.

