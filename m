From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] gianfar: Fix skb allocation strategy
Date: Fri, 25 Apr 2008 02:04:20 -0400
Message-ID: <48117464.4060301@pobox.com>
References: <1208902709-23557-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57223 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756087AbYDYGEW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:04:22 -0400
In-Reply-To: <1208902709-23557-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> gianfar was unable to handle failed skb allocation for rx buffers, so
> we were spinning until it succeeded.  Actually, it was worse--we were
> spinning for a long time, and then silently failing.  Instead, we take
> Stephen Hemminger's suggestion to try the allocation earlier, and drop the
> packet if it failed.
> 
> We also make a couple of tweaks to how buffer descriptors are set up.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>

applied


