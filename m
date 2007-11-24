From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] dm9601: Consolidate common parts of dm_write_*_async
Date: Fri, 23 Nov 2007 21:03:27 -0500
Message-ID: <4747866F.6020606@garzik.org>
References: <E1Iu9pB-0002xc-6M@nanv.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37006 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753559AbXKXCD3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 21:03:29 -0500
In-Reply-To: <E1Iu9pB-0002xc-6M@nanv.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Korsgaard wrote:
> dm_write_async and dm_write_reg_async are almost identical.
> Move common functionality to dm_write_async_helper (saves ~256b).
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
> ---
>  drivers/net/usb/dm9601.c |   53 +++++++++++----------------------------------
>  1 files changed, 13 insertions(+), 40 deletions(-)

applied #upstream


