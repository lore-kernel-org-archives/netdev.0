From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/10] net/macb: ethtool interface: add register dump
 feature
Date: Wed, 05 Sep 2012 17:32:08 -0400 (EDT)
Message-ID: <20120905.173208.1472160105562166368.davem@davemloft.net>
References: <cover.1346775479.git.nicolas.ferre@atmel.com>
	<fcd1c2443a30f23ffcd8de28328c5a382e2a2459.1346775479.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	havard@skinnemoen.net, plagnioj@jcrosoft.com, jamie@jamieiles.com,
	linux-kernel@vger.kernel.org, patrice.vilchez@atmel.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fcd1c2443a30f23ffcd8de28328c5a382e2a2459.1346775479.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Wed, 5 Sep 2012 11:00:54 +0200

> @@ -10,6 +10,9 @@
>  #ifndef _MACB_H
>  #define _MACB_H
>  
> +
> +#define MACB_GREGS_LEN 32

Please don't add such extraneous empty lines.  One empty line between
constructs is more than enough, and anything more is visually awkward.

Thanks.
