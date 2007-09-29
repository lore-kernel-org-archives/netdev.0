From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] mv643xx_eth: Check ETH_INT_CAUSE_STATE bit
Date: Sat, 29 Sep 2007 00:46:42 -0400
Message-ID: <46FDD8B2.2050406@pobox.com>
References: <20070928133043.GA779@xyzzy.farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Martyn Welch <martyn.welch@radstone.co.uk>
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48532 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751107AbXI2Eqt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Sep 2007 00:46:49 -0400
In-Reply-To: <20070928133043.GA779@xyzzy.farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dale Farnsworth wrote:
> Commit 468d09f8946d40228c56de26fe4874b2f98067ed masked the "state"
> interrupt (bit 20 of the cause register). This results in Radstone's
> PPC7D repeatedly re-entering the interrupt routine, locking up the
> board. The following patch returns the required handling for this
> interrupt. 
> 
> Signed-off-by: Martyn Welch <martyn.welch@radstone.co.uk>
> Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
> 
> ---
> Jeff, this is a bug fix.
> 
>  drivers/net/mv643xx_eth.c |    2 +-
>  drivers/net/mv643xx_eth.h |    4 +++-
>  2 files changed, 4 insertions(+), 2 deletions(-)

applied to #upstream-fixes


