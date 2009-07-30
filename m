From: Luciano Coelho <luciano.coelho@nokia.com>
Subject: Re: neigh_periodic_timer expires too often
Date: Thu, 30 Jul 2009 17:33:01 +0300
Message-ID: <4A71AF1D.9020000@nokia.com>
References: <4A717985.7060909@nokia.com> <4A719CDB.3060004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kristo Tero (Nokia-D/Tampere)" <Tero.Kristo@nokia.com>
To: ext Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:57398 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750960AbZG3OdL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 10:33:11 -0400
In-Reply-To: <4A719CDB.3060004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Thanks for your very quick response!

ext Eric Dumazet wrote:
> You are mixing two different problems here.
>
> First patch you link (from Stephen Hemminger) was using deferrable timer for
> individual entry (function neigh_timer_handler()). Probably not your
> current concern.
>
> Second patch you link (from me) was using a workqueue (instead of a timer)
> for garbage collection of whole table.
>   

Yes, it was the second patch that I saw as the most efficient way to 
deal with the problem.  I mentioned the first one because we were 
considering using deferrable timers until we saw your workqueue patch. ;)

> I bet you are more intested about the garbage collection problem
> (function neigh_periodic_timer()) so I could try to resurrect
> my patch. I guess at that time Parag didnt replied to my mail...
>
> If nobody cared, patch was not considered for inclusion. Thats all.
>   

Indeed, the interest seemed to have died out.  But I was not sure 
whether there had been some other discussions elsewhere and the decision 
had been not to take that patch because of some real technical reasons.  
I'm glad that was not the case ;)

> So please test it and tell me/us you like it :)
>   

I applied your patch on top of the 2.6.28 I'm using and will start 
testing it now.  I can also try to test it on top of 2.6.31-rc4 plus 
wireless-testing stuff, if needed.

I'll tell you that I liked your patch in a moment (I actually already 
liked it, but I'll wait until I know it works before I tell you ;)

-- 
Cheers,
Luca.

