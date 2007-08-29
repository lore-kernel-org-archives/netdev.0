From: John Heffner <jheffner@psc.edu>
Subject: Re: NCR, was [PATCH] make _minimum_ TCP retransmission timeout configurable
Date: Wed, 29 Aug 2007 18:58:12 -0400
Message-ID: <46D5FA04.1060600@psc.edu>
References: <5640c7e00708291432q6acde704od52247647a6b453@mail.gmail.com>	<20070829.144656.104048365.davem@davemloft.net>	<20070829151301.495f3d6e@freepuppy.rosehill.hemminger.net>	<20070829.152812.74548456.davem@davemloft.net> <20070829155106.43cf69eb@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ian.mcdonald@jandi.co.nz,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:56123 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757046AbXH2W6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 18:58:51 -0400
In-Reply-To: <20070829155106.43cf69eb@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 29 Aug 2007 15:28:12 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
>> And reading NCR some more, we already have something similar in the
>> form of Alexey's reordering detection, in fact it handles exactly the
>> case NCR supposedly deals with.  We do not trigger loss recovery
>> strictly on the 3rd duplicate ACK, and we've known about and dealt
>> with the reordering issue explicitly for years.
>>
> 
> Yeah, it looked like another case of BSD RFC writers reinventing
> Linux algorithms, but it is worth getting the behaviour standardized
> and more widely reviewed.

I don't believe this was the case.  NCR is substantially different, and 
came out of work at Texas A&M.  The original (only) implementation was 
in Linux IIRC.  Its goal was to do better.  Their papers say it does. 
It might be worth looking at.

In my own experience with reordering, Alexey's code had some 
hard-to-track-down bugs (look at all the work Ilpo's been doing), and 
the relative simplicity of NCR may be one of the reasons it does well in 
tests.

   -John
