From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] mv643xx_eth: Fix use of uninitialized port_num field
Date: Wed, 28 Mar 2007 02:19:14 -0400
Message-ID: <460A08E2.4080904@garzik.org>
References: <20070323123002.GA23436@iram.es> <20070323190351.GB28209@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gabriel Paubert <paubert@iram.es>,
	Manish Lachwani <mlachwani@mvista.com>, netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42315 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753200AbXC1GTY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 02:19:24 -0400
In-Reply-To: <20070323190351.GB28209@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> From: Gabriel Paubert <paubert@iram.es>
> 
> In this driver, the default ethernet address is first set by by calling
> eth_port_uc_addr_get() which reads the relevant registers of the
> corresponding port as initially set by firmware. However that function
> used the port_num field accessed through the private area of net_dev
> before it was set.
> 
> The result was that one board I have ended up with the unicast address
> set to 00:00:00:00:00:00 (only port 1 is connected on this board). The
> problem appeared after commit 84dd619e4dc3b0b1c40dafd98c90fd950bce7bc5.
> 
> This patch fixes the bug by setting mp->port_num prior to calling
> eth_port_uc_get_addr().
> 
> Signed-off-by: Gabriel Paubert <paubert@iram.es>
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> ---

applied #1 to upstream-fixes


