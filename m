From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 08:17:42 -0400
Message-ID: <1181650662.4060.72.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>
	 <1181639998.29767.59.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.227]:21695 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753070AbXFLMRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jun 2007 08:17:48 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1768826wxc
        for <netdev@vger.kernel.org>; Tue, 12 Jun 2007 05:17:47 -0700 (PDT)
In-Reply-To: <1181639998.29767.59.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-12-06 at 11:19 +0200, Johannes Berg wrote:
> On Mon, 2007-06-11 at 08:23 -0400, jamal wrote:

> > Sure. Packets stashed on the any DMA ring are considered "gone to the
> > wire". That is a very valid assumption to make.
> 
> Not at all! Packets could be on the DMA queue forever if you're feeding
> out more packets. Heck, on most wireless hardware packets can even be
> *expired* from the DMA queue and you get an indication that it was
> impossible to send them.

The spirit of the discussion you are quoting was much higher level than
that. Yes what you describe can happen on any DMA (to hard-disk etc)
A simpler example, if you tcpdump on an outgoing packet you see it on
its way to the driver - it is accounted for as "gone"[1].
In any case, read the rest of the thread.

cheers,
jamal

[1] Current Linux tcpdumping is not that accurate, but i dont wanna go
into that discussion

