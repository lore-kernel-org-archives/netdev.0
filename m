From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug 71591 - Temporary address re-generated when it should not (public address about to expire)
Date: Thu, 6 Mar 2014 17:43:09 +0100
Message-ID: <20140306164309.GB3092@order.stressinduktion.org>
References: <5318A47D.2020204@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Heiner Kallweit <heiner.kallweit@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45754 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbaCFQnK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 11:43:10 -0500
Content-Disposition: inline
In-Reply-To: <5318A47D.2020204@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2014 at 05:38:21PM +0100, Heiner Kallweit wrote:
> Recently I faced the issue that a public address was about to expire and 
> 3s before expiry a new temporary address was generated which instantly 
> went into deprecated state.
> This didn't do any harm however it's wrong IMHO. Problem seems to be in 
> function ipv6_create_tempaddr in addrconf.c.
> A new temporary address is generated if this condition is met: 
> tmp_prefered_lft > regen_advance
> tmp_prefered_lft however is an offset from tstamp, not from now.
> This condition only checks that the new address is preferred until more 
> than regen_advance from tstamp,
> but it should check that the new address is preferred until more than 
> regen_advance from now.
> 
> I submitted this issue to kernel bugzilla -> 71591
> Hannes asked me to propose a patch, here it comes.

You would need to follow Documentation/SubmittingPatches and provide a proper
signed-off-by.

Basically if scripts/checkpatch.pl --strict doesn't complain on your patch any
more, then you're ready to submit.

Otherwise the patch looks good to me.

Thanks,

  Hannes
