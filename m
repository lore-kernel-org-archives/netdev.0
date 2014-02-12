From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv4: arp: process only if ipv4 address configured
Date: Wed, 12 Feb 2014 10:26:27 -0800
Message-ID: <1392229587.1752.11.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1392226067-21736-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:52156 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672AbaBLS0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:26:30 -0500
Received: by mail-pd0-f170.google.com with SMTP id p10so9346776pdj.29
        for <netdev@vger.kernel.org>; Wed, 12 Feb 2014 10:26:29 -0800 (PST)
In-Reply-To: <1392226067-21736-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-12 at 18:27 +0100, Florian Westphal wrote:
> 8030f54499925d073a88c09f ([IPV4] devinet: Register inetdev earlier.)
> changed arp behaviour (2.6.22 onwards).
> 
> Before this, inetdev_init() was called only when the first address was
> added to the interface, i.e. arp_process always dropped incoming arp
> packets as __in_dev_get_rcu() returned NULL when no IP address was set
> on the interface.
> 
> With >= 2.6.22 we now process arp packets even if no address is assigned.
> It can cause issues if the machine has several interfaces in the same
> segment; requests receive answers from multiple macs.


What about arp_filter value/meaning ?
