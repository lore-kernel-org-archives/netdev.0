From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'jg-20061103-00' tag
Date: Mon, 06 Nov 2006 03:01:09 -0500
Message-ID: <454EEBC5.3070408@garzik.org>
References: <20061103205606.GA5723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32898 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1161198AbWKFIBL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Nov 2006 03:01:11 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061103205606.GA5723@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from tag 'jg-20061103-00' in repository
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git jg-20061103-00
> 
> to get the changes below.
> 
> Distance from 'upstream-fixes'
> -----------------------------
> 
> 17fddc34b36fc26aa8b5f130fe32b446d9d88fa2
> 
> Diffstat
> --------
> 
>  drivers/net/r8169.c |   22 ++++++++++++++++++++--
>  1 files changed, 20 insertions(+), 2 deletions(-)
> 
> Shortlog
> --------
> 
> Francois Romieu:
>       r8169: perform a PHY reset before any other operation at boot time

This warrants much more testing than pushing into 2.6.19-rc4 would give 
us, so I'm pulling it into #upstream.

In the past, with 10/100 hubs or ancient Cisco switches, we really 
didn't want to reset the phy and restart autonegotiation, because that 
might be problematic.

In any case, this is a behavior change that may solve problems... but 
also needs testing to insure that it doesn't also cause problems.

	Jeff


