From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC PATCH 3/6] firewire net: Export fwnet_peerinfo structure
 for ieee1394-specific peer information in ARP/NDP.
Date: Sat, 12 Jan 2013 15:59:29 +0100
Message-ID: <20130112155929.20a3d789@stein>
References: <50F17162.4060005@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:59990 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab3ALO7q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:59:46 -0500
In-Reply-To: <50F17162.4060005@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 YOSHIFUJI Hideaki wrote:
[...]
> --- /dev/null
> +++ b/include/net/firewire.h
> @@ -0,0 +1,11 @@
> +#ifndef _NET_FIREWIRE_H
> +#define _NET_FIREWIRE_H
> +
> +struct fwnet_peerinfo {
> +	u8 max_rec;		/* Sender's max packet size		*/
> +	u8 sspd;		/* Sender's max speed			*/
> +	__be16 fifo_hi;		/* hi 16bits of sender's FIFO addr	*/
> +	__be32 fifo_lo;		/* lo 32bits of sender's FIFO addr	*/
> +} __packed;
> +
> +#endif

If it is deemed necessary to put definitions of on-the-wire formats of the
RFC 2734 or RFC 3146 encapsulations into include/net/, then fine by me.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
