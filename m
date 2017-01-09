From: Matthew Hall <mhall@mhcomputing.net>
Subject: Re: bad interaction between privacy extensions, prefix lifetimes and
 protocols that maintain long-term connections.
Date: Mon, 9 Jan 2017 13:41:42 -0800
Message-ID: <20170109214142.GA6465@mhcomputing.net>
References: <9769f6b7-946c-1279-110f-15de8ec40022@p10link.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: debian-ipv6@lists.debian.org, netdev@vger.kernel.org
To: peter green <plugwash@p10link.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from master.mhcomputing.net ([74.208.228.170]:46528 "EHLO
        mail.mhcomputing.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752155AbdAIVrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 16:47:47 -0500
Content-Disposition: inline
In-Reply-To: <9769f6b7-946c-1279-110f-15de8ec40022@p10link.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 07, 2017 at 03:16:06PM +0000, peter green wrote:
> For the main MAC-based address the valid_lft is always short but it is 
> updated by new RAs so the address remains valid.
> 
> However privacy addresses inherit their valid_lft from the main MAC-based 
> address and unlike the main address it is not updated causing the addresses 
> to time out. I believe that the timeout of these privacy addresses is what 
> is causing my repeated disconnections from IRC.

Privacy addresses generally cause me nothing but absolute misery.

Despite the MAC address problem I usually end up disabling them just to be 
able to survive without losing my sanity due to issues like this one.

I have had all kinds of applications not work reliably because of them. 
Including Google Chrome / Chromium etc. IRC also seems like a likely victim, 
but I wouldn't have noticed because I use it from a system with a static 
address.

Perhaps a workaround would be using the MAC address override ability in the 
interfaces file pre-up script with "ip link set eth0 address 02:01:02:03:04:08".
Randomly generate one fake MAC per boot.

Matthew.
