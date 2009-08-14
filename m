From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH net-2.6] can: Use WARN_ONCE() instead of BUG_ON() for
 sanity check in receive path
Date: Fri, 14 Aug 2009 10:11:56 +0200
Message-ID: <4A851C4C.8060704@hartkopp.net>
References: <4A80040D.3030009@hartkopp.net>	<20090812.220123.234730484.davem@davemloft.net>	<4A84FCAE.10309@hartkopp.net> <20090814.001322.146991956.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, l.fu@pengutronix.de,
	m.olbrich@pengutronix.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:12527 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbZHNIME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 04:12:04 -0400
In-Reply-To: <20090814.001322.146991956.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Fri, 14 Aug 2009 07:57:02 +0200
> 
>> David Miller wrote:
>>> From: Oliver Hartkopp <oliver@hartkopp.net>
>>> Date: Mon, 10 Aug 2009 13:27:09 +0200
>>>
>>>> Additionally it changes the return values to the common NET_RX_xxx constants.
>>> Don't munge unrelated changes together like this, split it up.
>>>
>>> Also, this is not net-2.6 material, I will only apply these changes
>>> to net-next-2.6 at this point.
>> No problem.
>>
>> Btw. this patch was removed from patchwork and i was not able to find it in
>> your latest net-next-2.6 push this morning.
> 
> It's not in net-next-2.6 because I didn't apply it, which is pretty
> clealy implied when I'm asking you to split the change up into
> multiple patches.

Sorry - i assumed this to be a hint for the next time. My fault.

> 
> When I ask for changes, I mark the patch in patchwork with the
> "changes requested" state and expect you to send me new updated stuff.
> 
> You can look for patches in various "done" states by simply modifying
> the "Filters" setting in the patch list.

Ah! I only had the filters on 'action required' and therefore is was not able
to see what happened after the patches were removed from the 'action required'
view ...

I'll re-send two separate patches for net-next-2.6 .

Thanks,
Oliver
