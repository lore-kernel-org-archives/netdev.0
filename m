From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4
 devices
Date: Fri, 8 Mar 2013 09:53:40 +0100
Message-ID: <20130308085339.GA792@x61s.8.8.8.8>
References: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
 <1362696088.2936.47.camel@bwh-desktop.uk.solarflarecom.com>
 <1362697025.15793.221.camel@edumazet-glaptop>
 <20130307.181751.2267151221127000913.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:62048 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995Ab3CHIw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 03:52:28 -0500
Received: by mail-bk0-f45.google.com with SMTP id i18so604206bkv.32
        for <netdev@vger.kernel.org>; Fri, 08 Mar 2013 00:52:26 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20130307.181751.2267151221127000913.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 07, 2013 at 06:17:51PM -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 07 Mar 2013 14:57:05 -0800
> 
> > On Thu, 2013-03-07 at 22:41 +0000, Ben Hutchings wrote:
> >> On Thu, 2013-03-07 at 21:13 +0100, Alexander Aring wrote:
> >> > The function addrconf_ifid_eui64 will copy eui into dev->dev_addr.
> >> > We need first to manipulate eui[0] before we call memcpy afterwards.
> >> 
> >> memcpy() does not work that way.
> >> 
> >> > Broken since commit:
> >> > 5e98a36ed4bf6ea396170e3af0dd4fcbe51d772f
> >> > 
> >> > Since this commit I got many trouble with the ieee802154 stack.
> >> 
> >> Your change is effectively reverting that commit.
> > 
> > Reverting the commit seems the solution ;)
> 
> So Yoshifuji HIDEAKI and Alexander need to work out what is happening
> here.

Ok, I will try that. Maybe somebody with a another 802.15.4 device with
6lowpan on linux-zigbee-devel mailinglist can confirm that?

I have a at86rf231 device.

Alex
