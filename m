From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] sky2: turn off Rx checksum on bad hardware
Date: Fri, 09 Mar 2007 11:52:27 -0500
Message-ID: <45F190CB.2070101@garzik.org>
References: <20070308124230.208b7c9a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57818 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767403AbXCIQw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 11:52:28 -0500
In-Reply-To: <20070308124230.208b7c9a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Yukon FE, occasional hardware receive checksum errors are seen.
> An early indication of the problem is single bit differences in the two
> checksum engines.  Use this as a detection mechanism to turn off Rx
> checksumming.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> ---
>  drivers/net/sky2.c |   24 +++++++++++++++++++++---
>  1 file changed, 21 insertions(+), 3 deletions(-)

applied


