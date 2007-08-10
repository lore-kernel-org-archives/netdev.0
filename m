From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] IP_RECVERRC
Date: Fri, 10 Aug 2007 16:02:14 +0200
Message-ID: <20070810140214.GA10331@one.firstfloor.org>
References: <1186752912.5188.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46877 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762272AbXHJOCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 10:02:16 -0400
Content-Disposition: inline
In-Reply-To: <1186752912.5188.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 10, 2007 at 09:35:12AM -0400, jamal wrote:
> 
> It seems there are a lot of dumbass apps (latest i have found is iperf
> when analyzing batching results) out there whose performance is affected
> if they dont set IP_RECVERR. 

Affected in what way? 

> If you set that option though you end up getting all these skbs back

IP_RECVERR just delivers ICMPs. Do you mean those with "all these skbs" ?

> to the app which i see as unnecessary work if i am uninterested. I would
> like to not do a recvmsg to find out what those messages are - rather
> just receiving any errors back.
> My proposal is to add another option which is mutually exclusive with
> IP_RECVERR that allows for errors only.

What ICMPs do you not want? 

-Andi
