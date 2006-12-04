From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 08:58:45 -0500
Message-ID: <1165240725.3664.72.camel@localhost>
References: <1165158707.3517.92.camel@localhost>
	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>
	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:26291 "EHLO
	wr-out-0506.google.com") by vger.kernel.org with ESMTP
	id S936851AbWLDN6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 08:58:51 -0500
Received: by wr-out-0506.google.com with SMTP id i7so1539146wra
        for <netdev@vger.kernel.org>; Mon, 04 Dec 2006 05:58:51 -0800 (PST)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45742964.9000905@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-04-12 at 14:57 +0100, Patrick McHardy wrote:

>  I think the complications come from the fact that you remeber two
>  policies, but only one seems necessary.  How about this (completely
>  untested) patch? It simply uses increasing sequence numbers for all
>  but the last entry and uses zero for the last one.
> 

I could give this a try in about 2 hours. But why dont you like the
callback approach? You have to admit, this is hairy code.

> And the same for SAs.
> 

The SA has less things to remember, so it is easier; but i will apply
this and test it and if it meets the requirements I will look into
converting the SA to the same scheme.

cheers,
jamal


