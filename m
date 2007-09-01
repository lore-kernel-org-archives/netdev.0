From: Daniele Venzano <venza@brownhat.org>
Subject: Re: pktgen terminating condition
Date: Sat, 01 Sep 2007 12:47:24 +0200
Message-ID: <1188643644-77674666b52f8e4df330ca0982689109@brownhat.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mandeep Baines <mandeep.baines@gmail.com>, davem@davemloft.net,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, jeff@garzik.org,
	nhorman@tuxdriver.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.infomaniak.ch ([84.16.68.90]:59458 "EHLO
	smtp2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbXIAKsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 06:48:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Message d'origine -----
De: jamal <hadi@cyberus.ca>
Date: Fri, 31 Aug 2007 09:50:03 -0400
Sujet: Re: Re: pktgen terminating condition

>I dont know if you followed the discussion - by defering the freeing of
>skbs, you will be slowing down socket apps sending from the local
>machine. It may be ok if the socket buffers were huge, but that comes at
>the cost of system memory (which may not be a big deal)
>Do you by any chance recall why you used the idle interupt instead of
>txok to kick the prunning of tx descriptors?

That should be asked to the original author of the driver, that I wasn't able to contact when I took over the maintainership several years ago.
I think that since this chip is usually used on cheap/low performance (relatively speaking) devices it was felt that generating an interrupt for each transmitted packet was going to affect the performance of the system too much. At the start, if I remember correctly, this was a chip thought for consumer use, where transmissions won't happen continuously for long periods of time. Then the sis900 started to get used everywhere, from embedded systems to (cheap) server motherboards and the usage scenario changed.


--
Daniele Venzano
venza@brownhat.org
