From: Koen Kooi <koen@dominion.thruhere.net>
Subject: Re: cpts: Fix build error caused by include of plat/clock.h
Date: Fri, 14 Dec 2012 10:55:56 +0100
Message-ID: <45364223-10C6-430A-9085-9DE1C79030AF@dominion.thruhere.net>
References: <20121213213641.GF4989@atomide.com> <20121214071300.GA2253@netboy.at.omicron.at>
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Tony Lindgren <tony@atomide.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:52346 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754314Ab2LNJz7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 04:55:59 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so1185557eaa.19
        for <netdev@vger.kernel.org>; Fri, 14 Dec 2012 01:55:58 -0800 (PST)
In-Reply-To: <20121214071300.GA2253@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Op 14 dec. 2012, om 08:13 heeft Richard Cochran <richardcochran@gmail.com> het volgende geschreven:

> On Thu, Dec 13, 2012 at 01:36:41PM -0800, Tony Lindgren wrote:
>> Commit 87c0e764 (cpts: introduce time stamping code and a PTP hardware clock)
>> mistakenly included plat/clock.h that should not be included by drivers
>> even if it exists.
> 
> Hasn't this already been fixed?
> 
>  https://patchwork.kernel.org/patch/1810481/
>  http://www.spinics.net/lists/linux-omap/msg83132.html

That patch didn't get applied, so it's still broken in Linus' tree :(

regards,

Koen