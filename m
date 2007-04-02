From: "Gary Zambrano" <zambrano@broadcom.com>
Subject: Re: [PATCH 2.6.21-rc5] b44: fix IFF_ALLMULTI handling of CAM
 slots
Date: Mon, 02 Apr 2007 08:11:09 -0700
Message-ID: <1175526669.3035.3.camel@dhcp-10-12-136-115.broadcom.com>
References: <1175447428.9384.4.camel@tomato>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: "Bill Helfinstine" <bhelf@flitterfly.whirpon.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2567 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932808AbXDBQ2v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 12:28:51 -0400
In-Reply-To: <1175447428.9384.4.camel@tomato>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-04-01 at 10:10 -0700, Bill Helfinstine wrote:
> 
> If you set the IFF_ALLMULTI flag on a b44 device, or if you join more
> than
> B44_MCAST_TABLE_SIZE multicast groups, the device will stop receiving
> unicast
> messages.  This is because the __b44_set_mac_addr call sets the zeroth
> CAM
> entry to the MAC address of the device, and then the loop at line 1722
> proceeds to overwrite it unless the value of i is set by the
> __b44_load_mcast
> call.  However, when IFF_ALLMULTI is set, that call is bypassed,
> leaving i set
> to zero. 
> 
> Fixed by starting the loop at 1 to make it skip the CAM entry for the
> MAC
> address.
> 
> Signed-off-by: Bill Helfinstine <bhelf@flitterfly.whirpon.com>

Thanks.

Acked-by: Gary Zambrano <zambrano@broadcom.com>


