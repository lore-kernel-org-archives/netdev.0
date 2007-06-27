From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] 8139cp dev->tx_timeout
Date: Wed, 27 Jun 2007 04:36:18 -0400
Message-ID: <46822182.5070002@garzik.org>
References: <OFC04C6285.18455C26-ONC2257306.00364F82-C2257307.002CFBE9@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mika.Lansirinne@stonesoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38678 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752890AbXF0IgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Jun 2007 04:36:20 -0400
In-Reply-To: <OFC04C6285.18455C26-ONC2257306.00364F82-C2257307.002CFBE9@stonesoft.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mika.Lansirinne@stonesoft.com wrote:
> Hello All,
> 
> We have been experimenting a couple of interface hangs with the 8139cp
> driver. It appears that the tx buffer stops transmitting and never starts
> up again in some yet unknown conditions. To be able to circumvent this we
> implemented the missing dev->tx_timeout function which should reset the
> interface and allow it work again.
> 
> The problem reoccurs quite seldom and we have yet to be able to confirm
> that the attached patch helps the situation. We though that we should
> submit the patch anyway for reviewing.
> 
> The patch is made against 2.6.21.5 kernel.

Seems OK, but I'm definitely interested in hearing test feedback.

Also, all patches need a Signed-off-by line per 
Documentation/SubmittingPatches or
http://linux.yyz.us/patch-format.html

	Jeff


