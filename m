From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Don't limit the number of tunnels with generic name
 explicitly.
Date: Tue, 26 Feb 2008 13:31:25 -0800 (PST)
Message-ID: <20080226.133125.21157292.davem@davemloft.net>
References: <47BD70B8.3030507@openvz.org>
	<20080223.202021.191612366.davem@davemloft.net>
	<47C3C420.1060407@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40187
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762124AbYBZVak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 16:30:40 -0500
In-Reply-To: <47C3C420.1060407@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 26 Feb 2008 10:47:44 +0300

> That's because you skipped the first patch titled "Don't create 
> tunnels with '%' in name.", which adds the dev_alloc_name() call 
> and tosses the error paths a bit. Without this first patch, these 
> four drivers become broken :( When user doesn't specify the name, 
> the device's name will be e.g. "tunl%d", but not "tunl0" like 
> he expects.

Please respin and post the first patch, I had no idea there was a
dependency.
