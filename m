From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/4] ibmveth: Implement ethtool hooks to enable/disable
 checksum offload
Date: Wed, 18 Jul 2007 18:33:30 -0400
Message-ID: <469E953A.5090806@garzik.org>
References: <11846854701127-patch-mail.ibm.com> <200707171517.l6HFHwf2015030@d03av04.boulder.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, rcjenn@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Brian King <brking@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33050 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751961AbXGRWdc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jul 2007 18:33:32 -0400
In-Reply-To: <200707171517.l6HFHwf2015030@d03av04.boulder.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brian King wrote:
> This patch adds the appropriate ethtool hooks to allow for enabling/disabling
> of hypervisor assisted checksum offload for TCP.
> 
> Signed-off-by: Brian King <brking@linux.vnet.ibm.com>
> ---
> 
>  linux-2.6-bjking1/drivers/net/ibmveth.c |  120 +++++++++++++++++++++++++++++++-
>  linux-2.6-bjking1/drivers/net/ibmveth.h |    1 
>  2 files changed, 119 insertions(+), 2 deletions(-)

ACK.  As noted in previous email, with this, module option is not needed


