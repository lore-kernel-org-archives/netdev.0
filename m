From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] smc911x irq sense request and MPR2 board support
Date: Tue, 02 Oct 2007 13:35:24 -0400
Message-ID: <4702815C.8060508@pobox.com>
References: <200708200836.51182.super.firetwister@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Mark Jonas <toertel@gmail.com>
To: Markus Brunner <super.firetwister@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41173 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268AbXJBRf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:35:26 -0400
In-Reply-To: <200708200836.51182.super.firetwister@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Markus Brunner wrote:
> Hi,
> 
> this are the changes to the smc911x driver, which were necessary
> to get it running on the Magic Panel R2 (smsc9115).
> It is a SH3-DSP based board. The other patches are available on 
> the linuxsh-dev mailinglist.
> http://marc.info/?l=linuxsh-dev&r=1&b=200708&w=2
> 
> It was necessary to set the irq sense to low level.
> Therefor the SMC_IRQ_SENSE define was added.
> How are the chances for inclusion in 2.6.24?
> 
> Signed-off by: Markus Brunner <super.firetwister@gmail.com>
> Signed-off by: Mark Jonas <toertel@gmail.com>
> ---
>  Kconfig   |    2 +-
>  smc911x.c |    2 +-
>  smc911x.h |    6 ++++++

applied


