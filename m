From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH 07/15] net: Add driver helper functions to determine
 checksum offloadability
Date: Sun, 22 Nov 2015 10:14:59 +0000
Message-ID: <CO2PR11MB0088ACDD5D75DE3CE8D66CAB97180@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1447962961-2106059-1-git-send-email-tom@herbertland.com>
 <1447962961-2106059-8-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "kernel-team@fb.com" <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0139.outbound.protection.outlook.com ([157.56.110.139]:49472
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750971AbbKVKaF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Nov 2015 05:30:05 -0500
In-Reply-To: <1447962961-2106059-8-git-send-email-tom@herbertland.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +struct skb_csum_offl_spec {
...
> +			no_encapped_ipv6:1,
...
> +};

I don't think it's actually checked by this patch.
