From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH] xfrm: use printk instead of WARN for bad policy reporting
Date: Thu, 28 Jul 2016 06:57:47 +0200
Message-ID: <20160728045747.GH5710@gauss.secunet.com>
References: <1469003555-30599-1-git-send-email-vegard.nossum@oracle.com>
 <20160720121520.GD3775@gauss.secunet.com>
 <57984EA6.3040205@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	<netdev@vger.kernel.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:33780 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361AbcG1E5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2016 00:57:54 -0400
Content-Disposition: inline
In-Reply-To: <57984EA6.3040205@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 08:03:18AM +0200, Vegard Nossum wrote:
> Subject: [PATCH] xfrm: get rid of incorrect WARN
> 
> AFAICT this message is just printed whenever input validation fails.
> This is a normal failure and we shouldn't be dumping the stack over it.
> 
> Looks like it was originally a printk that was maybe incorrectly
> upgraded to a WARN:
> 
> commit 62db5cfd70b1ef53aa21f144a806fe3b78c84fab
> Author: stephen hemminger <shemminger@vyatta.com>
> Date:   Wed May 12 06:37:06 2010 +0000
> 
>     xfrm: add severity to printk
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Steffen Klassert <steffen.klassert@secunet.com>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>

Applied to the ipsec tree, thanks!
