From: Dale Farnsworth <dale@farnsworth.org>
Subject: Re: [PATCH 25/39] mv643xx_eth: massively simplify multicast
	address crc8 computation
Date: Thu, 5 Jun 2008 05:05:08 -0700
Message-ID: <20080605120508.GJ3807@farnsworth.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-26-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xyzzy.farnsworth.org ([65.39.95.219]:51234 "EHLO
	xyzzy.farnsworth.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755623AbYFEMFP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 08:05:15 -0400
Content-Disposition: inline
In-Reply-To: <1212490974-23719-26-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 03, 2008 at 01:02:40PM +0200, Lennert Buytenhek wrote:
> Replace the 70-line crc8 computation (used for multicast address
> filtering tables) by a 5-line version.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   95 ++++++++++-----------------------------------
>  1 files changed, 21 insertions(+), 74 deletions(-)

Wow!

Acked-by: Dale Farnsworth <dale@farnsworth.org>
