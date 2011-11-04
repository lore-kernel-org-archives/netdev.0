From: David Miller <davem@redhat.com>
Subject: Re: [PATCH] macvlan: receive multicast with local address
Date: Fri, 04 Nov 2011 17:40:05 -0400 (EDT)
Message-ID: <20111104.174005.1467761740413516054.davem@redhat.com>
References: <20111102151153.028e222f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58659 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752214Ab1KDVkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Nov 2011 17:40:09 -0400
In-Reply-To: <20111102151153.028e222f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Nov 2011 15:11:53 -0700

> When implementing VRRP v2 using macvlan several problems were
> discovered.  VRRP is weird in that all routers participating
> in a redundant group use the same virtual MAC address.
> Macvlan is a natural driver to use for this but it doesn't
> work.  The problem is that packets with a macvlan device's
> source address are not received.
> 
> The problem is actually a regression that date back almost 2 years now.
> The original problems started with:
> 
> commit 618e1b7482f7a8a4c6c6e8ccbe140e4c331df4e9
> Author: Arnd Bergmann <arnd@arndb.de>
> Date:   Thu Nov 26 06:07:10 2009 +0000
> 
>     macvlan: implement bridge, VEPA and private mode
>     
> This patches restores the original 2.6.32 behavior. Allowing multicast
> packets received with the VRRP source address to be received.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied and queued up for -stable, thanks.
