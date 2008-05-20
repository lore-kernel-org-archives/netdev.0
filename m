From: David Miller <davem@davemloft.net>
Subject: Re: [VLAN]: Correctly handle device notifications for layered VLAN
 devices
Date: Tue, 20 May 2008 14:38:01 -0700 (PDT)
Message-ID: <20080520.143801.00974740.davem@davemloft.net>
References: <4832D0D6.3020503@trash.net>
	<4832D15B.3070003@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761264AbYETViH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 17:38:07 -0400
In-Reply-To: <4832D15B.3070003@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 20 May 2008 17:25:47 +0400

> Patrick McHardy wrote:
> > commit cf794e6af782a838252dfc9fc6f10f7a7f66f62a
> > Author: Patrick McHardy <kaber@trash.net>
> > Date:   Tue May 20 15:12:49 2008 +0200
> > 
> >     [VLAN]: Correctly handle device notifications for layered VLAN devices
> > 
> >     Commit 30688a9 ([VLAN]: Handle vlan devices net namespace changing)
> >     changed the device notifier to special-case notifications for VLAN
> >     devices, effectively disabling state propagation to underlying VLAN
> >     devices. This is needed for layered VLANs though, so restore the
> >     original behaviour.
> > 
> >     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> Acked-by: Pavel Emelyanov <xemul@openvz.org>

Applied and I'll queue up to -stable if relevant...

Thanks!
