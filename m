From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Assign the inner mode output function to the dst
 entry
Date: Tue, 10 May 2011 12:28:09 -0700 (PDT)
Message-ID: <20110510.122809.115943941.davem@davemloft.net>
References: <20110510053638.GB8013@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53088
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751567Ab1EJT2l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:28:41 -0400
In-Reply-To: <20110510053638.GB8013@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 10 May 2011 07:36:38 +0200

> As it is, we assign the outer modes output function to the dst entry
> when we create the xfrm bundle. This leads to two problems on interfamily
> scenarios. We might insert ipv4 packets into ip6_fragment when called
> from xfrm6_output. The system crashes if we try to fragment an ipv4
> packet with ip6_fragment. This issue was introduced with git commit
> ad0081e4 (ipv6: Fragment locally generated tunnel-mode IPSec6 packets
> as needed). The second issue is, that we might insert ipv4 packets in
> netfilter6 and vice versa on interfamily scenarios.
> 
> With this patch we assign the inner mode output function to the dst entry
> when we create the xfrm bundle. So xfrm4_output/xfrm6_output from the inner
> mode is used and the right fragmentation and netfilter functions are called.
> We switch then to outer mode with the output_finish functions.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Applied.
