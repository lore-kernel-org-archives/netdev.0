From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3] tc: introduce OpenFlow classifier
Date: Fri, 10 Apr 2015 08:23:59 -0400 (EDT)
Message-ID: <20150410.082359.964457460073432676.davem@davemloft.net>
References: <1428584287-8197-1-git-send-email-jiri@resnulli.us>
	<20150409.173423.2258417584616634411.davem@davemloft.net>
	<20150410091203.GA2021@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56322 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755820AbbDJMYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 08:24:04 -0400
In-Reply-To: <20150410091203.GA2021@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 10 Apr 2015 11:12:03 +0200

> Thu, Apr 09, 2015 at 11:34:23PM CEST, davem@davemloft.net wrote:
>>However I am sure that I majorly object to having yet another flow
>>parsing engine.  Therefore, at least adjust this code to use our flow
>>dissector and datastructures.  Adjust the flow dissector to fit your
>>needs, if necessary.
> 
> Yep, Thomas already suggested the merge. The thing is, cls_flow uses
> linked list for doing lookups. That is not scalable. in cls_openflow I
> use rhashtable. Using rhashtable in cls_flow would break the existing
> assumption that first inrested filter would be first hit.

I'm talking about using net/core/flow_dissect.c's interfaces instead
of your by-hand header parsing.  This has nothing to do with cls_flow
