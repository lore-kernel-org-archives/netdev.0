From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/4] b44: timer power saving
Date: Wed, 13 Jun 2007 15:53:38 -0400
Message-ID: <46704B42.2040801@garzik.org>
References: <20070604202536.503165465@linux-foundation.org> <20070604202712.223155106@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gary Zambrano <zambrano@broadcom.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:39024 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbXFMTxl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 15:53:41 -0400
In-Reply-To: <20070604202712.223155106@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Make the PHY and statistic timer run on one second boundary
> for powersaving.
> 
> On resume, the driver should check for link up immediately, to
> get online faster (rather than waiting for the next second).
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> ---
>  drivers/net/b44.c |    9 ++++-----
>  1 file changed, 4 insertions(+), 5 deletions(-)

applied 1-4 to #upstream


