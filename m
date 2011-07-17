From: David Lamparter <equinox@diac24.net>
Subject: Re: iproute2: Add 802.1ad / QinQ support
Date: Sun, 17 Jul 2011 23:11:59 +0200
Message-ID: <20110717211158.GA3352722@jupiter.n2.diac24.net>
References: <1310936105-3494206-1-git-send-email-equinox@diac24.net>
 <1310936903-26251-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:60164 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751271Ab1GQVME (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Jul 2011 17:12:04 -0400
Content-Disposition: inline
In-Reply-To: <1310936903-26251-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

probably should've put "iproute2" in the subject line... sorry.

-David

On Sun, Jul 17, 2011 at 11:08:23PM +0200, David Lamparter wrote:
> +		} else if (matches(*argv, "protocol") == 0) {
> +			NEXT_ARG();
> +			if (strcmp(*argv, "802.1Q") == 0)
> +				proto = 0x8100;
> +			else if (strcmp(*argv, "802.1ad") == 0)
> +				proto = 0x88a8;
> +			else if (strcmp(*argv, "9100") == 0)
> +				proto = 0x9100;
> +			else if (strcmp(*argv, "9200") == 0)
> +				proto = 0x9200;
> +			else if (strcmp(*argv, "9300") == 0)
> +				proto = 0x9300;
> +			else
> +				invarg("protocol is invalid", *argv);
> +			addattr_l(n, 1024, IFLA_VLAN_PROTOCOL, &proto, 2);
