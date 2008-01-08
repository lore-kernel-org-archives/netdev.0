From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-2.6.25 6/6][NETFILTER] Use the ctl paths instead of
 hand-made analogue
Date: Tue, 08 Jan 2008 17:13:30 +0100
Message-ID: <4783A12A.3060207@trash.net>
References: <47839C30.2040402@openvz.org> <4783A0D1.4010202@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63695 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753340AbYAHQR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 11:17:27 -0500
In-Reply-To: <4783A0D1.4010202@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> The conntracks subsystem has a similar infrastructure
> to maintain ctl_paths, but since we already have it
> on the generic level, I think it's OK to switch to
> using it.
> 
> So, basically, this patch just replaces the ctl_table-s
> with ctl_path-s, nf_register_sysctl_table with 
> register_sysctl_paths() and removes no longer needed code.

Also looks good, thanks. But please remeber to CC netfilter-devel
on patches affecting netfilter.

> After this the net/netfilter/nf_sysctl.c file contains 
> the paths only.

That sounds like they should be moved to net/netfilter/core.c
instead and the file removed. I can take care of that once
your patches are in Dave's tree.
