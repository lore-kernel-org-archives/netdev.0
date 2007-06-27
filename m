From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV6] MIP6: Loadable module support for MIPv6.
Date: Tue, 26 Jun 2007 23:56:44 -0700 (PDT)
Message-ID: <20070626.235644.90119583.davem@davemloft.net>
References: <11799066192758-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45060
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751151AbXF0G4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2007 02:56:24 -0400
In-Reply-To: <11799066192758-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: nakam@linux-ipv6.org
Date: Wed, 23 May 2007 16:50:19 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> This patch makes MIPv6 loadable module named "mip6".
> 
> Here is a modprobe.conf(5) example to load it automatically
> when user application uses XFRM state for MIPv6:
> 
> alias xfrm-type-10-43 mip6
> alias xfrm-type-10-60 mip6
> 
> Some MIPv6 feature is not included by this modular, however,
> it should not be affected to other features like either IPsec
> or IPv6 with and without the patch.
> We may discuss XFRM, MH (RAW socket) and ancillary data/sockopt
> separately for future work.
> 
> Loadable features:
> * MH receiving check (to send ICMP error back)
> * RO header parsing and building (i.e. RH2 and HAO in DSTOPTS)
> * XFRM policy/state database handling for RO
> 
> These are NOT covered as loadable:
> * Home Address flags and its rule on source address selection
> * XFRM sub policy (depends on its own kernel option)
> * XFRM functions to receive RO as IPv6 extension header
> * MH sending/receiving through raw socket if user application
>   opens it (since raw socket allows to do so)
> * RH2 sending as ancillary data
> * RH2 operation with setsockopt(2)
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied, thank you!
