From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 08:52:15 -0400
Message-ID: <1181566335.4043.231.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>
	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>
	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>
	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:22452 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497AbXFKMwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:52:19 -0400
Received: by py-out-1112.google.com with SMTP id a29so2595451pyi
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 05:52:18 -0700 (PDT)
In-Reply-To: <466D4284.1030004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-06 at 14:39 +0200, Patrick McHardy wrote:
> jamal wrote:
> > On Mon, 2007-11-06 at 13:58 +0200, Patrick McHardy wrote:
> > 

> > Sure. Packets stashed on the any DMA ring are considered "gone to the
> > wire". That is a very valid assumption to make.
> 
> 
> I disagree, its obviously not true 

Patrick, you are making too strong a statement. Take a step back:
When you put a packet on the DMA ring, are you ever going to take it
away at some point before it goes to the wire? 

> and leads to the behaviour I
> described. If it were true there would be no reason to use multiple
> HW TX queues to begin with.

In the general case, they are totaly useless.
They are  useful when theres contention/congestion. Even in a shared
media like wireless. 
And if there is contention, the qdisc scheduler will do the right thing.

cheers,
jamal

