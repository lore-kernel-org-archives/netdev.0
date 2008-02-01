From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Fri, 01 Feb 2008 01:04:27 +0000
Message-ID: <47A2701B.4040104@andyfurniss.entadsl.com>
References: <20080131124632.GA25299@basil.nowhere.org>	<47A212CB.1060403@hp.com>	<20080131190326.GF4671@one.firstfloor.org>	<47A214FE.3050200@hp.com> <20080131192521.GG4671@one.firstfloor.org> <47A21E1A.6000006@hp.com>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.ukfsn.org ([77.75.108.10]:40421 "EHLO mail.ukfsn.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1765693AbYBABHn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 20:07:43 -0500
In-Reply-To: <47A21E1A.6000006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:

> then the qdisc could/should place a cap on the size of a 'TSO' based on 
> the bitrate (and perhaps input as to how much time any one "burst" of 
> data should be allowed to consume on the network) and pass that up the 
> stack?  right now you seem to be proposing what is effectively a cap of 
> 1 MSS.

I don't have any gig nics to test, so this is not a rhetorical question.

How does tcp congestion control behave when a tc qdisc drops a big 
unsegmented TSO skb?

Andy.
