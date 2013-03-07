From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4
 devices
Date: Thu, 07 Mar 2013 14:57:05 -0800
Message-ID: <1362697025.15793.221.camel@edumazet-glaptop>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
	 <1362696088.2936.47.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Aring <alex.aring@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:51298 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab3CGW5I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 17:57:08 -0500
Received: by mail-pb0-f52.google.com with SMTP id ma3so705150pbc.25
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 14:57:07 -0800 (PST)
In-Reply-To: <1362696088.2936.47.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-03-07 at 22:41 +0000, Ben Hutchings wrote:
> On Thu, 2013-03-07 at 21:13 +0100, Alexander Aring wrote:
> > The function addrconf_ifid_eui64 will copy eui into dev->dev_addr.
> > We need first to manipulate eui[0] before we call memcpy afterwards.
> 
> memcpy() does not work that way.
> 
> > Broken since commit:
> > 5e98a36ed4bf6ea396170e3af0dd4fcbe51d772f
> > 
> > Since this commit I got many trouble with the ieee802154 stack.
> 
> Your change is effectively reverting that commit.


Reverting the commit seems the solution ;)
