From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 2.6.17] net/ipv6/udp.c: remove duplicate udp_get_port
 code
Date: Sat, 26 Aug 2006 20:07:16 -0700 (PDT)
Message-ID: <20060826.200716.85410384.davem@davemloft.net>
References: <200608171325.47349@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:24552
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751148AbWH0DHU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Aug 2006 23:07:20 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200608171325.47349@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: gerrit@erg.abdn.ac.uk
Date: Thu, 17 Aug 2006 13:25:46 +0100

> [NET]: UDPv4 and UDPv6 use an almost identical version of the get_port function,
> which is unnecessary since the (long) code differs in only one if-statement.
> 
> This patch creates one common function which is called by udp_v4_get_port() and
> udp_v6_get_port(). As a result,
>   * duplicated code is removed
>   * udp_port_rover and local port lookup can now be removed from udp.h
>   * further savings follow since the same function will be used by UDP-Litev4 
>     and UDP-Litev6
> 
> In contrast to the patch sent in response to Yoshifujis comments (fixed by this
> variant), the code below also removes the EXPORT_SYMBOL(udp_port_rover), since
> udp_port_rover can now remain local to net/ipv4/udp.c.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Applied, and I marked udp_port_rover "static" for
good measure.

Thanks.

