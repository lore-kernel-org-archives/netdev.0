From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: Established connections hash function
Date: Fri, 23 Mar 2007 09:17:19 +0100
Message-ID: <46038D0F.1060507@cosmosbay.com>
References: <391F64D0A7C5463CA2D70362E4B3E7EC@XEON>
 <20070322182156.GB17793@2ka.mipt.ru> <1199CE22A40740D28833A585014BE559@XEON>
 <20070322.135834.74723088.davem@davemloft.net>
 <20070323080715.GB29991@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>, nikb@webmaster.com,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604001mt.neufgp.fr ([84.96.92.60]:41641 "EHLO Smtp.neuf.fr"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422657AbXCWIR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 04:17:28 -0400
Received: from [192.168.30.10] ([86.66.237.19]) by sp604001mt.gpm.neuf.ld
 (Sun Java System Messaging Server 6.2-5.05 (built Feb 16 2006))
 with ESMTP id <0JFC009BXKCRXKG1@sp604001mt.gpm.neuf.ld> for
 netdev@vger.kernel.org; Fri, 23 Mar 2007 09:17:16 +0100 (CET)
In-reply-to: <20070323080715.GB29991@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov a ecrit :
> Call me a loooser which mail will be deleted on arrival, but...
> 
> jhash_2words(const, const, ((const << 16) | $sport) ^ $random)
> 
> where $sport is 1-65535 in a loop, and $random is pseudo-random number
> obtained on start.
> 
> Which is exactly the case of web server and attacker connects to 80 port
> from the same IP address and different source ports.
> 
> Result with jenkins:
> 1 23880
> 2 12108
> 3 4040
> 4 1019
> 5 200
> 6 30
> 7 8
> 8 1
> 
> Xor:
> 1 65536

So what ? You still think hash function must be bijective ? Come on !

You have a machine somewhere that allows 65536 concurrent connections coming 
from the same IP address ?

The last problem you have is the nature of tcp hash function.

Dont argue again with your pseudo science.

