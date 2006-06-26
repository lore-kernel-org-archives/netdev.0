From: Bill Fink <billfink@mindspring.com>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 26 Jun 2006 00:20:13 -0400
Message-ID: <20060626002013.55514734.billfink@mindspring.com>
References: <4492D5D3.4000303@atmos.washington.edu>
	<44948EF6.1060201@atmos.washington.edu>
	<Pine.LNX.4.61.0606191638550.23553@ask.diku.dk>
	<200606191724.31305.ak@suse.de>
	<Pine.LNX.4.61.0606192017370.31662@ask.diku.dk>
	<449F0570.2090001@atmos.washington.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpauth04.mail.atl.earthlink.net ([209.86.89.64]:7810 "EHLO
	smtpauth04.mail.atl.earthlink.net") by vger.kernel.org with ESMTP
	id S932272AbWFZEUT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 00:20:19 -0400
To: Harry Edmon <harry@atmos.washington.edu>
In-Reply-To: <449F0570.2090001@atmos.washington.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 25 Jun 2006, Harry Edmon wrote:

> I understand the saying "beggars can't be choosers", but I have heard nothing on 
> this issue since June 19th.  Does anyone have any ideas on what is going on?  Is 
> there more information I can collect that would help diagnose this problem?  And 
> again, thanks for any and all help!

Harry,

I'd suggest checking all the ethtool configuration settings
(ethtool -a, -c, -g, -k) and statistics (ethtool -S) for both
the working and problematic kernels, and then comparing them
to see if anything jumps out at you.  Also compare ifconfig
settings and dmesg output.  Check /proc/interrupts to see if
there is any difference with the interrupt routing.  Check
sysctl.conf and rc.local for any special system configuration
or device settings that might differ between the systems.

The one thing that has caused me a lot of network performance
issues on e1000 is having TSO enabled, so if that is enabled
(check with ethtool -k), then I'd try disabling it to see if
that helps.

					-Hope this helps

					-Bill
