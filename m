From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: Re: [PATCH net-next V2 00/16] net: fec: cleanup and fixes
Date: Thu, 25 Feb 2016 09:05:34 -0700
Message-ID: <56CF264E.2070903@boundarydevices.com>
References: <1456360619-24390-1-git-send-email-troy.kisky@boundarydevices.com>
 <5514193.TiF8b6rKpj@diplodocus>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com,
	fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, johannes@sipsolutions.net,
	sergei.shtylyov@cogentembedded.com, arnd@arndb.de
To: Joshua Clayton <stillcompiling@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33537 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932407AbcBYQFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:05:35 -0500
Received: by mail-pa0-f54.google.com with SMTP id fl4so34256634pad.0
        for <netdev@vger.kernel.org>; Thu, 25 Feb 2016 08:05:35 -0800 (PST)
In-Reply-To: <5514193.TiF8b6rKpj@diplodocus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/24/2016 7:52 PM, Joshua Clayton wrote:
> Hello Troy,
> I'm replying here instead of to a particular commit because several of
> the commit messages seem inadequate.
> 
> The first line summaries all look good.
> 
> The descriptions should each also include the "user visible impact" of
> the patch and the justification for it (i.e. why you made the change).
> 
> For instance, patch 3 doesn't include either what will change
>  (nothing, I'm guessing?) or why we now pass in the structures
> instead of a queue_id. 

I can add to the commit message, that this is in preparation for
patch 4 which depends on it. Or I could squash patches 2/3/4
together, but I think it is easier to review smaller patches.


> 
> You've also got a few (e.g. patch 9, patch 14) where the substance
> of the patch is in the summary,
> 
> but missing from the message.
> 
> These kind of descriptions are very hard to review since the expression
> is split between the subject of the email and the body of the email, which
> are not close
> together in some email programs.
> 
> Better to reiterate or elaborate on the summary in the message.
> In patch 9, for instance, it would be more clear to say:
> 
> Move restart test to earlier in fec_txq() which saves one comparison. 


I can do this. And change patch 14 to read


Create subroutine reset_tx_queue to have one place
to release any queued tx skbs.

Any other commit messages you'd like to improve?


> P.S I'm a little confused, as I came looking for a v3 of the first 8 patches
> and found these instead. I'll try to give your first 8 a look when they show up.

The 1st 8 patches have already been applied. I added a patch to address your review there
at the end of the series. So, that patch will show up in my next set.


Thanks for the review

Troy
