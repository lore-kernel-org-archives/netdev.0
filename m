From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC IPROUTE 00/08]: Time cleanups + nano-second clock resolution
 support
Date: Wed, 14 Mar 2007 09:54:58 +0100
Message-ID: <45F7B862.4010700@trash.net>
References: <20070304191402.22838.91224.sendpatchset@localhost.localdomain> <20070313144253.430ef008@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33865 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933898AbXCNIzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 04:55:15 -0400
In-Reply-To: <20070313144253.430ef008@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Sun,  4 Mar 2007 20:14:53 +0100 (MET)
> Patrick McHardy <kaber@trash.net> wrote:
> 
>>Patrick McHardy:
>>      [IPROUTE]: tbf: fix latency printing
>>      [IPROUTE]: Use tc_calc_xmittime() where appropriate
>>      [IPROUTE]: Introduce tc_calc_xmitsize and use where appropriate
>>      [IPROUTE]: Introduce TIME_UNITS_PER_SEC to represent internal clock resolution
>>      [IPROUTE]: Replace "usec" by "time" in function names
>>      [IPROUTE]: Add sprint_ticks() function and use in CBQ
>>      [IPROUTE]: Handle different kernel clock resolutions
>>      [IPROUTE]: Increase internal clock resolution to nsec
> 
> 
> applied all

Thanks Stephen, but actually I think the last patch (increase clock
resolution) shouldn't go in yet. I'm not done yet looking at all
the compatibility issues and it does change the range of valid
values for everything dealing with times. Most places I looked
at still accept reasonable ranges, but I would feel more comfortable
to make sure everything is fine first.

