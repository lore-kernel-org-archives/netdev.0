From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [VLAN]: Correctly handle device notifications for layered VLAN
 devices
Date: Tue, 20 May 2008 17:25:47 +0400
Message-ID: <4832D15B.3070003@openvz.org>
References: <4832D0D6.3020503@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:50664 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760204AbYETN2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2008 09:28:20 -0400
In-Reply-To: <4832D0D6.3020503@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> commit cf794e6af782a838252dfc9fc6f10f7a7f66f62a
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Tue May 20 15:12:49 2008 +0200
> 
>     [VLAN]: Correctly handle device notifications for layered VLAN devices
> 
>     Commit 30688a9 ([VLAN]: Handle vlan devices net namespace changing)
>     changed the device notifier to special-case notifications for VLAN
>     devices, effectively disabling state propagation to underlying VLAN
>     devices. This is needed for layered VLANs though, so restore the
>     original behaviour.
> 
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Pavel Emelyanov <xemul@openvz.org>
