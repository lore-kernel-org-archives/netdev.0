From: Frans Pop <elendil@planet.nl>
Subject: Re: [RFC PATCHv2] printk: add the %pM, %p4, %p6 format specifiers
Date: Mon, 27 Oct 2008 02:21:06 +0100
Message-ID: <200810270221.08675.elendil@planet.nl>
References: <1224892008.3919.27.camel@johannes.berg> <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg> <20081026.010329.11475786.davem@davemloft.net> <1225009308.3478.22.camel@johannes.berg> <1225009822.3478.30.camel@johannes.berg> <1225047674.10060.10.camel@brick> <1225049591.3746.0.camel@johannes.berg> <1225049929.10060.11.camel@brick> <1225050015.3746.2.camel@johannes.berg> <1225060789.10060.13.camel@brick> <1225060789.10060.13.camel@brick> <1225067465.5672.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, davem@davemloft.net, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hpsmtp-eml11.KPNXCHANGE.COM ([213.75.38.111]:21058 "EHLO
	hpsmtp-eml11.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750710AbYJ0BVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 21:21:12 -0400
In-reply-To: <1225067465.5672.1.camel@brick>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey Harrison wrote:
> diff --git a/lib/vsprintf.c b/lib/vsprintf.c
> index a013bbc..eec3879 100644
> --- a/lib/vsprintf.c
> +++ b/lib/vsprintf.c
> @@ -592,6 +644,12 @@ static char *resource_string(char *buf, char *end,
> struct resource *res, int fie
>   * - 'S' For symbolic direct pointers
>   * - 'R' For a struct resource pointer, it prints the range of
>   *       addresses (not the name nor the flags)
> + * - 'M' For a 6-byte MAC address, it prints the address in the
> + *       usual colon-separated hex notation
> + * - '4' For a 4-byte IPv4 address, it prints the address in the
> + *       usual colon-separated hex notation
> + * - 'M' For a 16-byte IPv6 address, it prints the address in colon separated
> + *       big-endian 16 bit hex notation

Shouldn't that last one be '6' instead of 'M'?
