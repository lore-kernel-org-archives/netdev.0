From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] mv643xx_eth: make eth_port_uc_addr_{get,set}() calls
 symmetric
Date: Thu, 29 Mar 2007 08:35:18 -0400
Message-ID: <460BB286.2030706@garzik.org>
References: <20070323123002.GA23436@iram.es> <20070323190351.GB28209@xyzzy.farnsworth.org> <20070323190726.GA4736@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gabriel Paubert <paubert@iram.es>,
	Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52624 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753407AbXC2Mfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 08:35:46 -0400
In-Reply-To: <20070323190726.GA4736@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Gabriel Paubert <paubert@iram.es>
> 
> There is no good reason for the asymmetry in the parameters of
> eth_port_uc_addr_get() and eth_port_uc_addr_set().  Make them
> symmetric.  Remove some gratuitous block comments while we're here.
> 
> Signed-off-by: Gabriel Paubert <paubert@iram.es>
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> ---
> This is a clean-up patch that needn't be rushed upstream.  -Dale
> 
>  drivers/net/mv643xx_eth.c |   59 +++++++-----------------------------
>  drivers/net/mv643xx_eth.h |    4 --
>  2 files changed, 13 insertions(+), 50 deletions(-)

applied to #upstream


