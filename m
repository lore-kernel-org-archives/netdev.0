From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 28/39] mv643xx_eth: remove write-only interrupt
	coalescing variables
Date: Thu, 5 Jun 2008 05:53:01 -0700
Message-ID: <20080605125301.GZ3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-29-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:38163 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756817AbYFEMxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:53:06 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-29-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:43PM +0200, Lennert Buytenhek wrote:
> Remove the write-only ->[rt]x_int_coal members from struct
> mv643xx_eth_private.  In the process, tweak the RX/TX interrupt
> mitigation code so that it is compiled by default, and set the
> default coalescing delays to 0 usec.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   29 ++++-------------------------
>  1 files changed, 4 insertions(+), 25 deletions(-)

Acked-by: Dale Farnsworth <dale@farnsworth.org>
