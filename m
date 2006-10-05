From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] b44: fix multicast with >32 groups
Date: Thu, 05 Oct 2006 07:06:20 -0400
Message-ID: <4524E72C.4020904@garzik.org>
References: <451D95D5.5010005@flitterfly.whirpon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33245 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751676AbWJELGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 07:06:25 -0400
To: Bill Helfinstine <bhelf@flitterfly.whirpon.com>
In-Reply-To: <451D95D5.5010005@flitterfly.whirpon.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Helfinstine wrote:
> 
> The b44 driver has a bug where if there are more than 
> B44_MCAST_TABLE_SIZE groups in the dev->mc_list, it will only listen to 
> the first B44_MCAST_TABLE_SIZE that it sees.
> 
> This patch makes the driver go into RXCONFIG_ALLMULTI mode if there are 
> more than B44_MCAST_TABLE_SIZE groups being subscribed to.
> 
> This patch is against 2.6.18, b44.c version 1.01.
> 
> 
> Signed-off-by: Bill Helfinstine <bhelf@flitterfly.whirpon.com>

applied manually, due to whitespace damage

