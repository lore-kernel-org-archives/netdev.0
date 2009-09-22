From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: fix transmission where ZLP is expected
Date: Tue, 22 Sep 2009 14:19:45 -0700 (PDT)
Message-ID: <20090922.141945.211402736.davem@davemloft.net>
References: <1253628027-2704-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com,
	vlad.lyalikov@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52093
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbZIVVT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:19:27 -0400
In-Reply-To: <1253628027-2704-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 22 Sep 2009 15:00:27 +0100

> Usbnet framework assumes USB hardware doesn't handle zero length
> packets, but SMSC LAN95xx requires these to be sent for correct
> operation.
> 
> This patch fixes an easily reproducible tx lockup when sending a frame
> that results in exactly 512 bytes in a USB transmission (e.g. a UDP
> frame with 458 data bytes, due to IP headers and our USB headers).  It
> adds an extra flag to usbnet for the hardware driver to indicate that
> it can handle and requires the zero length packets.
> 
> This patch should not affect other usbnet users, please also consider
> for -stable.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks.
