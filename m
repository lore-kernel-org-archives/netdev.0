From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 14:39:32 +0200
Message-ID: <466D4284.1030004@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net> <1181564611.4043.220.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41552 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366AbXFKMmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:42:01 -0400
In-Reply-To: <1181564611.4043.220.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 13:58 +0200, Patrick McHardy wrote:
> 
> 
>>Thats not true. Assume PSL has lots of packets, PSH is empty. We
>>fill the PHL queue until their is no room left, so the driver
>>has to stop the queue. 
> 
> 
> Sure. Packets stashed on the any DMA ring are considered "gone to the
> wire". That is a very valid assumption to make.


I disagree, its obviously not true and leads to the behaviour I
described. If it were true there would be no reason to use multiple
HW TX queues to begin with.


>>[...]
> 
> i can see your thought process building -
> You are actually following what i am saying;->


I am :)
