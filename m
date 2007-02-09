From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ethtool: fix long statistics name
Date: Fri, 09 Feb 2007 16:32:26 -0500
Message-ID: <45CCE86A.60205@garzik.org>
References: <20070111153610.36d0f39a@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:60457 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752501AbXBIVcb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Feb 2007 16:32:31 -0500
In-Reply-To: <20070111153610.36d0f39a@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Fix handling of statistics where the label is exactly 32 (ETH_GSTRING_LEN)
> characters long (observed with chelsio 10G driver). 
> Before it would print garbage because of going by end
> of string. Don't need to copy string, just use formats properly.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> ---
>  ethtool.c |   10 ++++------
>  1 files changed, 4 insertions(+), 6 deletions(-)

applied


