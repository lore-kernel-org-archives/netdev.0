From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] qlge: Fix MSI/legacy single interrupt bug.
Date: Wed, 22 Oct 2008 07:01:13 -0400
Message-ID: <48FF07F9.8010407@garzik.org>
References: <20081020173026.GA27501@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, netdev@vger.kernel.org, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40048 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226AbYJVLBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Oct 2008 07:01:19 -0400
In-Reply-To: <20081020173026.GA27501@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Mercer wrote:
> The chip can issue spurious interrupts for single interrupt modes. We use disable to clear the condition and allow processing to continue. Also got rid of legacy specific code since it now needs to be done on MSI single irq also.
> 
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qlge/qlge.h      |    5 +--
>  drivers/net/qlge/qlge_main.c |   89 +++++++++++++++++++++--------------------
>  2 files changed, 47 insertions(+), 47 deletions(-)

applied


