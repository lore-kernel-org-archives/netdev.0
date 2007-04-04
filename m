From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.21-rc5] b44: fix IFF_ALLMULTI handling of CAM slots
Date: Tue, 03 Apr 2007 22:31:40 -0400
Message-ID: <46130E0C.5070603@pobox.com>
References: <1175447428.9384.4.camel@tomato>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zambrano@broadcom.com, netdev@vger.kernel.org
To: Bill Helfinstine <bhelf@flitterfly.whirpon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40247 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966289AbXDDCbp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2007 22:31:45 -0400
In-Reply-To: <1175447428.9384.4.camel@tomato>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Helfinstine wrote:
> If you set the IFF_ALLMULTI flag on a b44 device, or if you join more than
> B44_MCAST_TABLE_SIZE multicast groups, the device will stop receiving unicast
> messages.  This is because the __b44_set_mac_addr call sets the zeroth CAM
> entry to the MAC address of the device, and then the loop at line 1722
> proceeds to overwrite it unless the value of i is set by the __b44_load_mcast
> call.  However, when IFF_ALLMULTI is set, that call is bypassed, leaving i set
> to zero.  
> 
> Fixed by starting the loop at 1 to make it skip the CAM entry for the MAC
> address.
> 
> Signed-off-by: Bill Helfinstine <bhelf@flitterfly.whirpon.com>

applied


