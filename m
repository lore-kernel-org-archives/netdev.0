From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] r8169: issue request_irq after the private data are
 completely initialized
Date: Tue, 03 Apr 2007 22:31:49 -0400
Message-ID: <46130E15.9090807@garzik.org>
References: <20070402205959.GA23368@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jay Cliburn <jacliburn@bellsouth.net>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40256 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966190AbXDDCbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 22:31:53 -0400
In-Reply-To: <20070402205959.GA23368@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> The irq handler schedules a NAPI poll request unconditionally as soon as
> the status register is not clean. It has been there - and wrong - for
> ages but a recent timing change made it apparently easier to trigger.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/r8169.c |   33 ++++++++++++++++++---------------
>  1 files changed, 18 insertions(+), 15 deletions(-)

applied 1-2


