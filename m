From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 2/2] bugfixes and new hardware support for arcnet driver
Date: Sat, 17 Feb 2007 15:31:39 -0500
Message-ID: <45D7662B.2020502@garzik.org>
References: <200702160942.l1G9gRpM026492@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jmorrow@jmorrow.org,
	jmorrow@massspec.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47810 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932321AbXBQUbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Feb 2007 15:31:45 -0500
In-Reply-To: <200702160942.l1G9gRpM026492@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jeff Morrow <jmorrow@jmorrow.org>
> 
> The modifications and bug fixes noted below were done by Realtime Control
> Works and Contemporary Control Systems, Inc, Jan 2005.  They were
> incorporated into the 2.6 kernel by Jeff Morrow of Sierra Analytics, Feb
> 2007.  <jmorrow@massspec.com>
> 
> The changes have been tested on a Contemporary Controls PCI20U-4000.
> 
> Summary of changes:
> 
> Arc-rawmode.c:
>       rx():
>       - Fixed error in received packet lengths; 256 byte packets were
>         being received as 257 bytes packets.
> 
>       prepare_tx():
>       - Fixed error in transmit length calcs; 257 byte packets were being
>         transmitted as 260 byte packets.
> 
> com20020.c:
>       com20020_check():
>       - We now load the SETUP2 register if the 'clockm' parameter is
>         non-zero, instead of checking for ARC_CAN_10MBIT. The user is
>         now responsible for whether or not SETUP2 is loaded.  If the
>         clock multiplier is non-zero, this means that the user wants a
>         baud rate greater than 2.5Mbps. This is not possible unless the
>         SETUP2 register is present (COM20020D, or COM20022). So, we're
>         relying on the user to be smart about what kind of chip he's
>         dealing with...
> 
> com20020-pci.c
>       - Added several entries to com20020pci_id_table[].
> 
> Signed-off-by: Jeff Morrow <jmorrow@massspec.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

applied



