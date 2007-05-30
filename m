From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 18:55:15 +0200
Message-ID: <465DAC73.6070507@trash.net>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>	 <1180536987.4109.19.camel@localhost>  <465D97F1.9090600@trash.net>	 <1180541401.4109.72.camel@localhost>  <465DA4E9.5060906@trash.net> <1180542897.4109.81.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43723 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751424AbXE3Q4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:56:00 -0400
In-Reply-To: <1180542897.4109.81.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-30-05 at 18:23 +0200, Patrick McHardy wrote:
> 
>>My classifier seperates them entirely. The only thing it keeps
>>in SFQ is the old classifier for compatibility, besides that its
>>exactly what you say. It should be easily possible to remove it
>>entirely and use my classifier in a compatible configuration
>>automatically.
>>
> 
> 
> If you removed it entirely (and had it as a separate classifier) IMO
> that would be a better approach. Then what you have is a pure FQ qdisc.
> In which case, you leave alone SFQ and have a new qdisc.


I could do that, but I'm perfectly happy with the qdisc part of SFQ.
Without the classifier SFQ is of course simply a FQ qdisc, all it
cares about is serving queues equally.
