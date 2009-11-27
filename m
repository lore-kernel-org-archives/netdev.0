From: David Miller <davem@davemloft.net>
Subject: Re: vlan: support "loose binding" to the underlying network device
Date: Thu, 26 Nov 2009 16:01:04 -0800 (PST)
Message-ID: <20091126.160104.73404375.davem@davemloft.net>
References: <4B0D6F6E.4090901@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56530
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751599AbZK0AAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 19:00:46 -0500
In-Reply-To: <4B0D6F6E.4090901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 25 Nov 2009 18:54:54 +0100

>     vlan: support "loose binding" to the underlying network device
>     
>     Currently the UP/DOWN state of VLANs is synchronized to the state of the
>     underlying device, meaning all VLANs are set down once the underlying
>     device is set down. This causes all routes to the VLAN devices to vanish.
>     
>     Add a flag to specify a "loose binding" mode, in which only the operstate
>     is transfered, but the VLAN device state is independant.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, thanks Patrick.
