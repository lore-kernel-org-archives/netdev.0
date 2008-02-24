From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] sky2: fix LED management
Date: Sun, 24 Feb 2008 00:11:41 -0500
Message-ID: <47C0FC8D.7040202@pobox.com>
References: <20080222160033.79649405@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50436 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756777AbYBXFLo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Feb 2008 00:11:44 -0500
In-Reply-To: <20080222160033.79649405@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> Fix problems in LED management, so ethtool -p works correctly on Yukon-EC
> and other chips. The driver was incorrectly setting the PHY LED overide bits.
> Moral: read the spec sheet, not the vendor driver.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> ---
>  drivers/net/sky2.c |   99 +++++++++++++++++------------------------------------
>  drivers/net/sky2.h |   21 +++++------
>  2 files changed, 44 insertions(+), 76 deletions(-)

applied


