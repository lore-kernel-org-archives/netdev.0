From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Mon, 21 Apr 2008 20:31:09 +0100
Message-ID: <480CEB7D.8070702@katalix.com>
References: <20080412115950.1cbb9cfa@core>	<m33apqomgf.fsf@maximus.localdomain>	<m33apjp32f.fsf@maximus.localdomain>	<20080418.153256.253949503.davem@davemloft.net> <m3ve2b9qe8.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alan@lxorguk.ukuu.org.uk,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:45794 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755085AbYDUTbY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 15:31:24 -0400
In-Reply-To: <m3ve2b9qe8.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Halasa wrote:
> David Miller <davem@davemloft.net> writes:
> 
>> I'll fix it properly because I know you won't do the work.
> 
> Great to read that.
> 
> Just few friendly after all notes so that you don't waste your time
> learning that yourself:
> - my patch didn't give us a third PPP implementation, we already have
>   three: generic PPP, syncppp and PPP for ISDN :-)
> - of those, both generic PPP and (I think) ISDN PPP are in a good
>   shape
> - generic PPP is specialized for dial-up async devices and has the
>   required features (in kernel and in userspace pppd) - auth,
>   multi-line, compression etc. It's a "lets give /dev/ttyS* a network
>   device" implementation.

Generic ppp isn't specialized at all, and it isn't limited to async 
serial devices. PPPoE, PPPoATM and L2TP use it.

> - ISDN PPP does for ISDN cards basically the same as generic PPP does
>   for terminals. They are completely different from syncppp as the
>   needs are completely different. Fixed-line PPP must be small and
>   fast, and self-contained.

<snip>

> That's why I came to an idea that leaving syncppp and the old drivers
> in their current bit-rotting state which nobody can really fix, and
> using another (fourth, and third when syncppp eventually dies) PPP
> implementation is the only way out of this situation.

Can you elaborate on why the code that uses syncppp can't use the 
generic ppp code together with a userspace ppp control protocol 
implementation like pppd?


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

