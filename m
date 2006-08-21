From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 06/14] ipw2100: Make ipw2100 depends on known working platforms
Date: Mon, 21 Aug 2006 10:52:15 +0100
Message-ID: <20060821095215.GB2770@infradead.org>
References: <20060821033748.GA5371@mail.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:48290 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S1751815AbWHUJwg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 05:52:36 -0400
To: Zhu Yi <yi.zhu@intel.com>
Content-Disposition: inline
In-Reply-To: <20060821033748.GA5371@mail.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 11:37:49AM +0800, Zhu Yi wrote:
> ipw2100 driver doesn't support big endian by now.

NACK.  Fix it instead.

>  	tristate "Intel PRO/Wireless 2100 Network Connection"
> -	depends on NET_RADIO && PCI
> +	depends on NET_RADIO && PCI && (X86 || X86_64 || IA64 || BROKEN)

There's a lot more little endian platforms than just the intel ones, aswell.

It seems you're totally unsuitable as a driver or subsystem maintainer if
you favour you own employer so much.

