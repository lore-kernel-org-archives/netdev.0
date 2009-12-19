From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netem/iproute2 solving correlated loss issues [2/5]
Date: Fri, 18 Dec 2009 20:01:58 -0800 (PST)
Message-ID: <20091218.200158.112585402.davem@davemloft.net>
References: <4B2B5A26.8050400@uniroma2.it>
	<4B2B6676.301@yahoo.it>
	<20091218093605.76903fe5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fabio.ludovici@yahoo.it, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41150
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753572AbZLSEB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 23:01:56 -0500
In-Reply-To: <20091218093605.76903fe5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 18 Dec 2009 09:36:05 -0800

> On Fri, 18 Dec 2009 12:24:38 +0100
> Fabio Ludovici <fabio.ludovici@yahoo.it> wrote:
> 
>> patch 2/5 : linux-2.6.32/net/sched/sch_netem.c
> 
> Could you send with official signed-off-by line please?
> 
> Need some style work to match kernel coding style (not a big issue).
> And it would be helpful to put in more descriptive variable names
> or documentation. But I will try and address these and resubmit,
> keeping you as original author.

I would like some kind of commit message which at least
explains what in the world this stuff is, how it works,
why we want it etc.

Furthermore it is fundamentally flawed in it's implementation
in that the user exported data structures cannot be changed,
you cannot change the layout and you absolutely cannot
change the size of these things or else various tool and
kernel combinations stop working.
