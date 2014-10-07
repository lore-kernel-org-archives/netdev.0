From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: sunvnet and ->xmit_more
Date: Tue, 7 Oct 2014 16:51:25 -0400
Message-ID: <20141007205125.GE31406@oracle.com>
References: <20141007192922.GA31406@oracle.com>
 <20141007.153829.1919460115976279645.davem@davemloft.net>
 <9BB04EDE-1842-4DB0-93BE-5186B2D187AB@oracle.com>
 <20141007.164649.587971614591244924.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Raghuram.Kothakota@oracle.com, netdev@vger.kernel.org,
	david.stevens@oracle.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28916 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750865AbaJGUva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:51:30 -0400
Content-Disposition: inline
In-Reply-To: <20141007.164649.587971614591244924.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (10/07/14 16:46), David Miller wrote:
> 
> Play with it, you'll see.

at the moment, there are enough fun and games just doing a 
"modload -r sunvnet; modload sunvnet" in a loop while running iperf.

I think running stably is as important as tput, no? :-) Lets fix
all the races first.

--Sowmini
