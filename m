From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] atl1: deal with hardware rx checksum bug
Date: Thu, 07 Aug 2008 01:56:21 -0400
Message-ID: <489A8E85.2080008@garzik.org>
References: <20080804190510.4029d91d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: csnook@redhat.com, netdev@vger.kernel.org
To: Jay Cliburn <jacliburn@bellsouth.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41682 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbYHGF41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 01:56:27 -0400
In-Reply-To: <20080804190510.4029d91d@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> The L1 hardware contains a bug that flags a fragmented IP packet
> as having an incorrect TCP/UDP checksum, even though the packet
> is perfectly valid and its checksum is correct.  There's no way to
> distinguish between one of these good packets and a packet that
> actually contains a TCP/UDP checksum error, so all we can do is
> allow the packet to be handed up to the higher layers and let it
> be sorted out there.
> 
> Add a comment describing this condition and remove the code that
> currently fails to handle what may or may not be a checksum error.
> 
> Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
> ---
>  drivers/net/atlx/atl1.c |   19 +++++++++++--------

applied


