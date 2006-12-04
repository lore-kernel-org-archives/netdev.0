From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 15:06:37 +0100
Message-ID: <45742B6D.7010509@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net> <1165240725.3664.72.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:20914 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936870AbWLDODa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 09:03:30 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165240725.3664.72.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2006-04-12 at 14:57 +0100, Patrick McHardy wrote:
> 
> 
>> I think the complications come from the fact that you remeber two
>> policies, but only one seems necessary.  How about this (completely
>> untested) patch? It simply uses increasing sequence numbers for all
>> but the last entry and uses zero for the last one.
>>
> 
> 
> I could give this a try in about 2 hours. But why dont you like the
> callback approach? You have to admit, this is hairy code.

Both ways are fine I guess. But the counting has almost no
overhead with the patch I sent, so I'm not sure if its worth
adding a callback (which still needs to get the last policy/SA
as argument, so that part won't get any nicer).

BTW, I'm not sure whether there are further requirements than
those you quoted, but according to that text, using 1 for
all but the last message would be fine as well :)

