From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Pull request for 'r8169-20060912-00' branch
Date: Tue, 12 Sep 2006 22:17:22 +0200
Message-ID: <20060912201722.GA29802@xi.wantstofly.org>
References: <20060912193531.GB4482@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:20189 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1030401AbWILURZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 16:17:25 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060912193531.GB4482@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 12, 2006 at 09:35:31PM +0200, Francois Romieu wrote:

> +	/*
> +	 * Magic spell: some iop3xx ARM board needs the TxDescAddrHigh
> +	 * register to be written before TxDescAddrLow to work.
> +	 * Switching from MMIO to I/O access fixes the issue as well.
> +	 */

Not that it matters much either way, but my impression was that this
was an 8110SB bug rather than an iop3xx bug, as the same iop3xx ARM
board sports a VIA PCI USB controller and a Silicon Image PCI SATA
controller, which both work without any problems.


cheers,
Lennert
