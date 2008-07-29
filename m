From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [RFC][PATCH 1/1] net: support for hardware timestamping
Date: Tue, 29 Jul 2008 20:27:01 +0200
Message-ID: <200807292027.01727.netdev@axxeo.de>
References: <1217290080-4251-1-git-send-email-opurdila@ixiacom.com> <200807291930.20033.netdev@axxeo.de> <200807292110.45320.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick Ohly <patrick.ohly@intel.com>, netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.axxeo.de ([82.100.226.146]:37100 "EHLO mail.axxeo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752743AbYG2S1L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 14:27:11 -0400
In-Reply-To: <200807292110.45320.opurdila@ixiacom.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Octavian,

Octavian Purdila schrieb:
> On Tuesday 29 July 2008, Ingo Oeser wrote:
> In here:
> 
> net/netfilter/xt_time.c
> 
> it seems that the skb->tstamp needs to be CPU time. 

Yeah, but not being off more than half a second should be ok
even for that obscure use case. 

If your objective is to measure time and relate it to wall clock time, 
your host clock should be close to that using NTP without any problems :-)

> Frankly I don't care about that, but the tstamp is also used in other places 
> like the IP and TCP code paths and I can't say that I barely understand that 
> part :) 
> 
> But if it is ok to use any kind of monotonic increasing timestamp, that will 
> solve my problem, indeed.

Great! :-)


Best Regards

Ingo Oeser
