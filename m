From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH net-next 0/1] fix vlan transmit performance
Date: Thu, 06 Dec 2012 19:10:58 -0500
Message-ID: <50C13412.9040600@myri.com>
References: <1354827296-12009-1-git-send-email-gallatin@myri.com> <1354837321.2828.86.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f174.google.com ([209.85.213.174]:57486 "EHLO
	mail-ye0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160996Ab2LGALB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 19:11:01 -0500
Received: by mail-ye0-f174.google.com with SMTP id m6so1196261yen.19
        for <netdev@vger.kernel.org>; Thu, 06 Dec 2012 16:11:00 -0800 (PST)
In-Reply-To: <1354837321.2828.86.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/06/12 18:42, Ben Hutchings wrote:

> 
> My answer would be: leave reorder_hdr enabled per default.  In fact,
> perhaps the VLAN driver's TX path should ignore it if the underlying
> device has non-zero vlan_features.  (It's already ignored if the
> underlying device has NETIF_F_VLAN_TX.)

Thanks for the feedback.  I knew I was missing something!
I will try your approach, unless you beat me to it.
I assume sfc is also impacted by this..?

Drew
