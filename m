From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPV4] Swap the ifa allocation with
 the"ipv4_devconf_setall" call
Date: Fri, 07 Dec 2007 23:55:57 -0800 (PST)
Message-ID: <20071207.235557.163989906.davem@davemloft.net>
References: <475910F1.1010007@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33629
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752459AbXLHHz6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Dec 2007 02:55:58 -0500
In-Reply-To: <475910F1.1010007@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 07 Dec 2007 12:22:57 +0300

> According to Herbert, the ipv4_devconf_setall should be called
> only when the ifa is added to the device. However, failed 
> ifa allocation may bring things into inconsistent state.
> 
> Move the call to ipv4_devconf_setall after the ifa allocation.
> 
> Fits both net-2.6 (with offsets) and net-2.6.25 (cleanly).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied to net-2.6, thanks Pavel.
