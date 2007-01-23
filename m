From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
Date: Tue, 23 Jan 2007 16:29:04 -0500
Message-ID: <45B67E20.8020309@pobox.com>
References: <20070123165225.GA20153@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thibaut VARENE <T-Bone@parisc-linux.org>,
	Jarek Poplawski <jarkao2@o2.pl>, mlachwani@mvista.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50882 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965156AbXAWV3s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 16:29:48 -0500
To: Dale Farnsworth <dale@farnsworth.org>
In-Reply-To: <20070123165225.GA20153@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
>>From Dale Farnsworth <dale@farnsworth.org>
> 
> mv643xx_eth: Fix race condition in mv643xx_eth_free_tx_descs
> 
> This bug was found and isolated by Thibaut VARENE <T-Bone@parisc-linux.org>
> and Jarek Poplawski <jarkao2@o2.pl>.  This patch is a modification of their
> fixes.  We acquire and release the lock for each descriptor that is freed
> to minimize the time the lock is held.
> 
> ---
> 
>  drivers/net/mv643xx_eth.c |   11 +++++++++--
>  1 file changed, 9 insertions(+), 2 deletions(-)

applied


