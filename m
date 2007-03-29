From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 03/10] strlcpy is smart enough
Date: Thu, 29 Mar 2007 08:19:14 -0400
Message-ID: <460BAEC2.1090104@garzik.org>
References: <200703270547.l2R5lM49008257@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, khali@linux-fr.org, osstklei@de.ibm.com,
	themann@de.ibm.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52465 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbXC2MTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 08:19:18 -0400
In-Reply-To: <200703270547.l2R5lM49008257@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Jean Delvare <khali@linux-fr.org>
> 
> strlcpy already accounts for the trailing zero in its length
> computation, so there is no need to substract one to the buffer size.
> 
> Signed-off-by: Jean Delvare <khali@linux-fr.org>
> Cc: Jan-Bernd Themann <themann@de.ibm.com>
> Cc: Thomas Klein <osstklei@de.ibm.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/ehea/ehea_ethtool.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

applied 3-5


