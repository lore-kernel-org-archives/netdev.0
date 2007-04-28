From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] forcedeth: improve NAPI logic
Date: Fri, 27 Apr 2007 20:10:54 -0400
Message-ID: <4632910E.6030408@garzik.org>
References: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mingo@elte.hu, aabdulla@nvidia.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48183 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757943AbXD1AK5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:10:57 -0400
In-Reply-To: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Ingo Molnar <mingo@elte.hu>
> 
> Another forcedeth.c thing: i noticed that its NAPI handler does not do
> tx-ring processing.  The patch below implements this - tested on DESC_VER_2
> hardware, with CONFIG_FORCEDETH_NAPI=y.
> 
> Signed-off-by: Ingo Molnar <mingo@elte.hu>
> Cc: Ayaz Abdulla <aabdulla@nvidia.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/forcedeth.c |    8 ++++++++
>  1 file changed, 8 insertions(+)

See thread comments -- this patch should be expanded.


