From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: save mac address on remove
Date: Thu, 29 Mar 2007 08:26:58 -0400
Message-ID: <460BB092.5080001@garzik.org>
References: <20070328205151.A22317@redline.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jacliburn@bellsouth.net, netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52537 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394AbXC2M1A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 08:27:00 -0400
In-Reply-To: <20070328205151.A22317@redline.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook wrote:
> From: Chris Snook <csnook@redhat.com>
> 
> Some atl1 boards get their MAC address written directly to the register
> by the BIOS during POST, rather than storing it in EEPROM that's
> accessible to the driver.  If the MAC register on one of these boards
> is changed and then the module is unloaded, the permanent MAC address
> will be forgotten until the box is rebooted.  We should save the
> permanent address during removal if we've been messing with it.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>

applied, even though its a hack


