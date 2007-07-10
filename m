From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] QE Ethernet driver writes to wrong register to mask interrupts
Date: Tue, 10 Jul 2007 12:26:29 -0400
Message-ID: <4693B335.8010402@garzik.org>
References: <11840718711477-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59996 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760839AbXGJQ0c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 12:26:32 -0400
In-Reply-To: <11840718711477-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
> The QE Ethernet driver was writing to the wrong register to mask interrupts.
> In ucc_geth_stop(), it was clearing UCCE instead of UCCM.
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>
> ---
>  drivers/net/ucc_geth.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

applied


