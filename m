From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Fix sparse errors in drivers/net/ibmveth.c
Date: Tue, 24 Apr 2007 14:02:41 -0400
Message-ID: <462E4641.6060604@pobox.com>
References: <20070417031314.BC404DDED4@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	santil@us.ibm.com
To: Michael Ellerman <michael@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40366 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754383AbXDXSCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Apr 2007 14:02:50 -0400
In-Reply-To: <20070417031314.BC404DDED4@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Ellerman wrote:
> drivers/net/ibmveth.c:96:46: error: marked inline, but without a definition
> drivers/net/ibmveth.c:96: warning: 'ibmveth_rxq_harvest_buffer' declared inline after being called
> drivers/net/ibmveth.c:96: warning: previous declaration of 'ibmveth_rxq_harvest_buffer' was here
> 
> Just let the compiler decide, as it happens gcc 4.~ inlines it anyway.
> 
> drivers/net/ibmveth.c:957:71: warning: Using plain integer as NULL pointer
> drivers/net/ibmveth.c:964:85: warning: Using plain integer as NULL pointer
> 
> Split the long lines as well, ugly, but < 80 columns.
> 
> Signed-off-by: Michael Ellerman <michael@ellerman.id.au>

applied


