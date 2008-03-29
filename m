From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 11/21] 3c509: convert to isa_driver and pnp_driver
Date: Fri, 28 Mar 2008 22:15:28 -0400
Message-ID: <47EDA640.6070904@garzik.org>
References: <200803282141.m2SLfNQG011831@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux@rainbow-software.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47918 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753998AbYC2CPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 22:15:32 -0400
In-Reply-To: <200803282141.m2SLfNQG011831@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Ondrej Zary <linux@rainbow-software.org>
> 
> Convert 3c509 driver to isa_driver and pnp_driver.  The result is that
> autoloading using udev and hibernation works with ISA PnP cards.  It also adds
> hibernation support for non-PnP ISA cards.
> 
> xcvr module parameter was removed as its value was not used.
> 
> Tested using 3 ISA cards in various combinations of PnP and non-PnP modes. 
> EISA and MCA only compile-tested.
> 
> Signed-off-by: Ondrej Zary <linux@rainbow-software.org>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c509.c |  729 +++++++++++++++++++++---------------------
>  1 file changed, 372 insertions(+), 357 deletions(-)

applied 11-19


