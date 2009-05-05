From: "Ronciak, John" <john.ronciak@intel.com>
Subject: RE: [PATCH] igb: Record hardware RX overruns in net_stats
Date: Tue, 5 May 2009 15:38:06 -0700
Message-ID: <273D38FBE7C6FE46A1689FCD014A0B8B49655903@azsmsx505.amr.corp.intel.com>
References: <1241435206.8115.104.camel@localhost.localdomain>
 <9929d2390905051147y71f34e4bu9f63edc1e5a253a2@mail.gmail.com>
 <20090505.115819.84151021.davem@davemloft.net>
 <Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hawk@comx.dk" <hawk@comx.dk>, netdev <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@diku.dk>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43955 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805AbZEEWiI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2009 18:38:08 -0400
In-Reply-To: <Pine.LNX.4.64.0905052249110.1294@ask.diku.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>Its really useful for diagnosing problems, and I'm betting 
>that this is a 
>real-life situation which people is going to experience. We 
>might as well 
>help our self to more easily identify this issue when people 
>report drop problems.
The problem is that the RNBC aren't dropped packets as the numbers you have show.  While we can agree that the MPC are the actual dropped packets and could eaily be be used in the fifo overflow count since the packets were really dropped.

>I think that both MPC and RNBC should be stored in 
>rx_fifo_errors (and of 
>cause still keeping them seperate to ethtool -S).
This would count RNBC packets as packets that the stack did not process, which it did.  The MPC packets were not processed by the stack and should be counted as dropped.  As you point out, both counts are available via ethtool -S.

>I'll post two patches with these changes tomorrow, for you evaluation.
Thanks, we look forward to see them.

Cheers,
John
-----------------------------------------------------------
"...that your people will judge you on what you can build, not what you destroy.", B. Obama, 2009 

 

