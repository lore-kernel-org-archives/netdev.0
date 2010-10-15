From: Samuel Ortiz <samuel@sortiz.org>
Subject: Re: [PATCH 1/7] drivers/net/irda/irtty-sir.c: Return -ENOMEM on
 memory allocation failure
Date: Fri, 15 Oct 2010 15:48:44 +0200
Message-ID: <1287150524.2608.0.camel@sortiz-mobl>
References: <1287147610-8041-1-git-send-email-julia@diku.dk>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Julia Lawall <julia@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:54336 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754659Ab0JONss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 09:48:48 -0400
In-Reply-To: <1287147610-8041-1-git-send-email-julia@diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julia,

On Fri, 2010-10-15 at 15:00 +0200, Julia Lawall wrote:
> From: Julia Lawall <julia@diku.dk>
> 
> In this code, 0 is returned on memory allocation failure, even though other
> failures return -ENOMEM or other similar values.
> 
> The initial value of ret as 0 is never used, so drop the initialization.
Thanks, patch applied to my irda-2.6 tree.

Cheers,
Samuel.


