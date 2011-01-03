From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_red: report backlog information
Date: Mon, 03 Jan 2011 12:13:44 -0800 (PST)
Message-ID: <20110103.121344.258122824.davem@davemloft.net>
References: <1294062755.2472.11.camel@mojatatu>
	<1294063372.2892.408.camel@edumazet-laptop>
	<1294078298.2892.1111.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, jarkao2@gmail.com, hawk@diku.dk, kaber@trash.net,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755550Ab1ACUNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jan 2011 15:13:13 -0500
In-Reply-To: <1294078298.2892.1111.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 03 Jan 2011 19:11:38 +0100

> Provide child qdisc backlog (byte count) information so that "tc -s
> qdisc" can report it to user.
> 
> packet count is already correctly provided.
> 
> qdisc red 11: parent 1:11 limit 60Kb min 15Kb max 45Kb ecn 
>  Sent 3116427684 bytes 1415782 pkt (dropped 8, overlimits 7866 requeues 0) 
>  rate 242385Kbit 13630pps backlog 13560b 8p requeues 0 
>   marked 7865 early 1 pdrop 7 other 0
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
