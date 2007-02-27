From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] netxen: do_rom_fast_write error handling
Date: Tue, 27 Feb 2007 04:39:26 -0500
Message-ID: <45E3FC4E.5080307@garzik.org>
References: <20070226145156.5c0424a3@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47658 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161114AbXB0Jja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Feb 2007 04:39:30 -0500
In-Reply-To: <20070226145156.5c0424a3@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Compiler warning spots real error!
> 
> The function do_rom_fast_read called in do_rom_fast_write can fail
> and leave data1 unset. This causes a compile warning.  
> The correct thing is to propagate the error out.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/netxen/netxen_nic_init.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)

applied


