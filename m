From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH 0/3] r8169 driver fixes
Date: Thu, 03 Feb 2011 20:01:03 +0100
Message-ID: <1296759663.8737.2.camel@ceranb.intra.cera.cz>
References: <20110203172557.GA9024@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hayes Wang <hayeswang@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12754 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756316Ab1BCTBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Feb 2011 14:01:21 -0500
In-Reply-To: <20110203172557.GA9024@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-02-03 at 18:26 +0100, Francois Romieu wrote:
> The following series includes Ivan Rx fifo overflow fix and similar
> changes I did after testing with various 8168 chipsets.
> 
> The series is available as
> git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r8169-davem
> 
> Distance from 'master' (2ba451421b23636c45fabfa522858c5c124b3673)
> -----------------------------------------------------------------
> 
> 0331b3b022b9724019e4c42fded4a01eaa6946f5
> 407786ae1960eef585f97bfa7625a36512925de0
> e4b6fa3d3d3db4fac32904ae12efe199de8efed0
> 
> Diffstat
> --------
> 
>  drivers/net/r8169.c |   41 ++++++++++++++++++++++++++++++++---------
>  1 files changed, 32 insertions(+), 9 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu (2):
>       r8169: RxFIFO overflow oddities with 8168 chipsets
>       r8169: prevent RxFIFO induced loops in the irq handler.
> 
> Ivan Vecera (1):
>       r8169: use RxFIFO overflow workaround for 8168c chipset
> 
Looks good.

Ivan

