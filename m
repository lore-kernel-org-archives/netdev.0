From: acme@conectiva.com.br
Subject: Re: [PATCH] IPv6: Allow Both IPv6 and IPv4 Sockets on the Same Port Number (IPV6_V6ONLY Support)
Date: Thu, 03 Oct 2002 00:55:19 -0300 (BRST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1033617319.3d9bbfa7cd15e@webmail.conectiva.com.br>
References: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021003.121350.119660876.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Quoting YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>: 
 
 
> +	 (((a)->s6_addr32[2]) == __constant_htonl(0x0000ffff))) 
 
Please use plain htonl, __constant_htonl is only needed in static 
initializations, in all other cases with constants as a parameter it 
generates the same code as htonl, so lets prefer using the shorter, 
more readable format. 
 
- Arnaldo 
 
