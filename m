From: acme@conectiva.com.br
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port Number (IPV6_V6ONLY Support)
Date: Thu, 03 Oct 2002 00:53:01 -0300 (BRST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1033617181.3d9bbf1d557a3@webmail.conectiva.com.br>
References: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI@conectiva.com.br, UNEXPECTED_DATA_AFTER_ADDRESS@.SYNTAX-ERROR
In-Reply-To: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Quoting YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>: 
 
> +#define IN6_IS_ADDR_V4MAPPED(a)				\ 
> +	((((a)->s6_addr32[0]) == 0) &&			\ 
> +	 (((a)->s6_addr32[1]) == 0) &&			\ 
> +	 (((a)->s6_addr32[2]) == __constant_htonl(0x0000ffff))) 
 
Please use plain htonl, __constant_htonl is only needed in static 
initializations, in all other cases with constants as a parameter it 
generates the same code as htonl, so lets prefer using the shorter, 
more readable format. 
 
- Arnaldo 
