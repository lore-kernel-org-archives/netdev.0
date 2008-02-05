From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 3/4] mv643xx_eth: fix byte order when checksum offload
 is enabled
Date: Tue, 05 Feb 2008 13:32:58 -0500
Message-ID: <47A8ABDA.4040202@garzik.org>
References: <200802050746.m157kur6010404@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, byron.bbradley@gmail.com,
	dale@farnsworth.org, mlachwani@mvista.com, viro@zeniv.linux.org.uk
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:42454 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752408AbYBESdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 13:33:03 -0500
In-Reply-To: <200802050746.m157kur6010404@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Byron Bradley <byron.bbradley@gmail.com>
> 
> The Marvell Orion system on chips have an integrated mv643xx MAC.  On these
> little endian ARM devices mv643xx will oops when checksum offload is
> enabled.  Swapping the byte order of the protocol and checksum solves this
> problem.
> 
> Signed-off-by: Byron Bradley <byron.bbradley@gmail.com>
> Cc: Dale Farnsworth <dale@farnsworth.org>
> Cc: Manish Lachwani <mlachwani@mvista.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/mv643xx_eth.c |   11 ++++++++---
>  1 file changed, 8 insertions(+), 3 deletions(-)

applied 3-4


