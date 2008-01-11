From: Chris Snook <csnook@redhat.com>
Subject: Re: Bonding : Monitoring of 4965 wireless card
Date: Fri, 11 Jan 2008 14:28:40 -0500
Message-ID: <4787C368.2080409@redhat.com>
References: <802012.38504.qm@web25708.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: patnel972-linux@yahoo.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38610 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbYAKT2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 14:28:49 -0500
In-Reply-To: <802012.38504.qm@web25708.mail.ukl.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

patnel972-linux@yahoo.fr wrote:
> Hi,
> 
> I want to make a bond with my wireless card. The ipw driver create two
>  interfaces (wlan0 and wmaster0). When i switch the rf_kill button,
>  ifplug detect wlan0 unplugged but not wmaster0. If i down wlan0 (while
>  rf_kil ), bonding detect the inactivity when i up the interface.
> 
> Have you some idea where is the problem? the driver or the miimon of
>  the module?
> 
> my module parameters mode=1 miimon=100 primary eth0

miimon isn't meaningful for wmaster0.  I suggest you use arp monitoring instead. 
  See bonding.txt for details.

	-- Chris
