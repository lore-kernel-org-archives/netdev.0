From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/1] myri10ge: Remove nonsensical limit in the tx done
 routine
Date: Mon, 16 Jul 2007 18:30:02 -0400
Message-ID: <469BF16A.4030001@garzik.org>
References: <4697C0E8.40003@myri.com> <4697C131.7070805@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37281 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762750AbXGPWaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 18:30:05 -0400
In-Reply-To: <4697C131.7070805@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brice Goglin wrote:
> Remove nonsensical limit in the tx done routine. Specifically,
> the loop will always terminate after processing <= 1 rings worth
> of frames, as the mcp index is not refetched, so the removed
> conditional could never be true.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>
> ---
>  drivers/net/myri10ge/myri10ge.c |    6 ------
>  1 file changed, 6 deletions(-)

applied


