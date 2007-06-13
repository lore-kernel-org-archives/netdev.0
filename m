From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] Blackfin ethernet driver: on chip ethernet MAC controller
 driver
Date: Wed, 13 Jun 2007 15:39:45 -0400
Message-ID: <46704801.1070107@garzik.org>
References: <1179912533.10328.26.camel@roc-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	torvalds@linux-foundation.org,
	Andrew Morton <akpm@linux-foundation.org>
To: bryan.wu@analog.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38834 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752401AbXFMTjt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 15:39:49 -0400
In-Reply-To: <1179912533.10328.26.camel@roc-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bryan Wu wrote:
> From: "Wu, Bryan" <bryan.wu@analog.com>
> 
> This patch implements the driver necessary use the Analog Devices
> Blackfin processor's on-chip ethernet MAC controller.
> 
> Signed-off-by: Bryan Wu <bryan.wu@analog.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/Kconfig    |   44 +
>  drivers/net/Makefile   |    1 
>  drivers/net/bfin_mac.c |  981 +++++++++++++++++++++++++++++++++++++++
>  drivers/net/bfin_mac.h |  147 +++++
>  4 files changed, 1173 insertions(+)

Finally got back to this.  Please run this patch through 
scripts/checkpatch.pl (found in latest linux-2.6.git upstream kernel 
tree), and follow most of the recommendations.

Personally I would ignore the lines slightly over 80 columns, but the 
other warnings look like real issues.

	Jeff



