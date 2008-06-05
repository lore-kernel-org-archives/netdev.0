From: Brent Cook <bcook@bpointsys.com>
Subject: Re: [PATCH 25/39] mv643xx_eth: massively simplify multicast address crc8 computation
Date: Thu, 5 Jun 2008 09:08:56 -0500
Message-ID: <200806050908.56427.bcook@bpointsys.com>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-26-git-send-email-buytenh@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Dale Farnsworth <dale@farnsworth.org>, netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.bpointsys.com ([70.253.197.130]:4250 "EHLO bpointsys.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755459AbYFEO2K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 10:28:10 -0400
In-Reply-To: <1212490974-23719-26-git-send-email-buytenh@wantstofly.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 June 2008 06:02:40 Lennert Buytenhek wrote:
> Replace the 70-line crc8 computation (used for multicast address
> filtering tables) by a 5-line version.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
>  drivers/net/mv643xx_eth.c |   95
> ++++++++++----------------------------------- 1 files changed, 21
> insertions(+), 74 deletions(-)
>

The original looks like someone ported Verilog code to C.
