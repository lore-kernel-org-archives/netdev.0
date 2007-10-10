From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] xen-netfront: rearrange netfront_info structure to separate
 tx and rx
Date: Tue, 09 Oct 2007 20:46:33 -0400
Message-ID: <470C20E9.9050405@garzik.org>
References: <470BCC1D.4080007@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keir Fraser <Keir.Fraser@cl.cam.ac.uk>,
	Stephen Hemminger <shemminge@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>
To: Jeremy Fitzhardinge <jeremy@goop.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44615 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752204AbXJJAqi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 20:46:38 -0400
In-Reply-To: <470BCC1D.4080007@goop.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeremy Fitzhardinge wrote:
> Keep tx and rx elements separate on different cachelines to prevent
> bouncing.
> 
> Signed-off-by: Jeremy Fitzhardinge <jeremy@xensource.com>
> Cc: Stephen Hemminger <shemminger@linux-foundation.org>
> Cc: Christoph Hellwig <hch@infradead.org>
> 
> ---
>  drivers/net/xen-netfront.c |   37 ++++++++++++++++++-------------------
>  1 file changed, 18 insertions(+), 19 deletions(-)

ACK but does not apply to jgarzik/netdev-2.6.git#upstream nor 
davem/net-2.6.24.git


