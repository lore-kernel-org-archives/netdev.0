From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH net-next 01/15] 6lowpan: lowpan_is_iid_16_bit_compressable()
 does not detect compressable address correctly
Date: Tue, 23 Oct 2012 09:04:08 +0200
Message-ID: <50864168.8000509@computer.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org> <1350965397-12384-2-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net,
	Alan Ott <alan@signal11.us>,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: Tony Cheneau <tony.cheneau@amnesiak.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay004.isp.belgacom.be ([195.238.6.170]:3256 "EHLO
	mailrelay004.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753450Ab2JWHFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 03:05:16 -0400
In-Reply-To: <1350965397-12384-2-git-send-email-tony.cheneau@amnesiak.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/2012 06:09 AM, Tony Cheneau wrote:

>  #define lowpan_is_iid_16_bit_compressable(a)	\
>  	((((a)->s6_addr16[4]) == 0) &&		\
> -	 (((a)->s6_addr16[5]) == 0) &&		\
> -	 (((a)->s6_addr16[6]) == 0) &&		\
> -	 ((((a)->s6_addr[14]) & 0x80) == 0))
> +	 (((a)->s6_addr[10]) == 0) &&		\
> +	 (((a)->s6_addr[11]) == 0xff) &&	\
> +	 (((a)->s6_addr[12]) == 0xfe) &&	\
> +	 (((a)->s6_addr[13]) == 0))
> +
>  
>  /* multicast address */
>  #define is_addr_mcast(a) (((a)->s6_addr[0]) == 0xFF)
> 

Is the additional newline needed at the end of the #define?
