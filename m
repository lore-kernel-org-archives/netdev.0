From: David Miller <davem@davemloft.net>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 04 Dec 2008 11:54:16 -0800 (PST)
Message-ID: <20081204.115416.174997306.davem@davemloft.net>
References: <20081204185022.6108d19e@gmail.com>
	<20081204.101805.45306327.davem@davemloft.net>
	<b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ldecicco@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: saverio.mascolo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54577
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750924AbYLDTyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 14:54:16 -0500
In-Reply-To: <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Date: Thu, 4 Dec 2008 20:05:22 +0100

>  the rationale of  VJ choice seems simple to me: if  the window is
> increased of one packet in one rtt, i can drop at most one packet in
> one rtt and so i have to recover only one packet in one rtt (note that
> rtt is the feedback reaction  time). If cwnd is increased of N packets
> i could drop N packets and i could need to recover N pkts. this is the
> problem here.

The bigger problem is that windows are so much larger now that going
back to the stone ages and newreno recovery behavior is absolutely not
an option any more.

So "go back to newreno" is not a suggestion to be taken seriously.
