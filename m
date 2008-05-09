From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next-2.6 3/3] [SCTP]: add sctp/remaddr table to
 complete RFC remote address table OID
Date: Fri, 09 May 2008 15:15:18 -0700 (PDT)
Message-ID: <20080509.151518.202869638.davem@davemloft.net>
References: <1210360481-16599-1-git-send-email-vladislav.yasevich@hp.com>
	<1210360566-16661-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, nhorman@tuxdriver.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42496
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758381AbYEIWPZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:15:25 -0400
In-Reply-To: <1210360566-16661-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  9 May 2008 15:16:06 -0400

> Add support for RFC3873 remote address table OID.
> 
>       +--(5) sctpAssocRemAddrTable
>       |   |
>       |   |--(-) sctpAssocId (shared index)
>       |   |
>       |   +--(1) sctpAssocRemAddrType (index)
>       .   |
>       .   +--(2) sctpAssocRemAddr (index)
>       .   |
>           +--(3) sctpAssocRemAddrActive
>           |
>           +--(4) sctpAssocRemAddrHBActive
>           |
>           +--(5) sctpAssocRemAddrRTO
>           |
>           +--(6) sctpAssocRemAddrMaxPathRtx
>           |
>           +--(7) sctpAssocRemAddrRtx
>           |
>           +--(8) sctpAssocRemAddrStartTime
> 
> This patch places all the requsite data in /proc/net/sctp/remaddr.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
