From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 14:01:15 +0200
Message-ID: <466D398B.2020900@trash.net>
References: <1181082517.4062.31.camel@localhost>	 <4666CEB7.6030804@trash.net> <1181168020.4064.46.camel@localhost>	 <20070606.153530.48530367.davem@davemloft.net> <1181172766.4064.83.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40825 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751359AbXFKMDl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 08:03:41 -0400
In-Reply-To: <1181172766.4064.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-06-06 at 15:35 -0700, David Miller wrote:
> 
>>The problem with this line of thinking is that it ignores the fact
>>that it is bad to not queue to the device when there is space
>>available, _even_ for lower priority packets.
> 
> 
> So use a different scheduler. Dont use strict prio. Strict prio will
> guarantee starvation of low prio packets as long as there are high prio
> packets. Thats the intent.


With a single queue state _any_ full HW queue will starve all other
queues, independant of the software queueing discipline.
