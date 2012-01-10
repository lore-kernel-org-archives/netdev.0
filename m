From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: "-w deadline" bug in ping/iputils- i will provide fix if you
 can tell me where owner of iputils is. Thanks.
Date: Tue, 10 Jan 2012 12:54:47 +0900
Message-ID: <4F0BB687.6070603@linux-ipv6.org>
References: <7D3B6706FA74174B8C1AC24710890745136F453C33@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	'Linus Torvalds' <torvalds@linux-foundation.org>
To: "Cloutier, Joseph (Joseph)" <joseph.cloutier@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46956 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756015Ab2AJDyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 22:54:50 -0500
In-Reply-To: <7D3B6706FA74174B8C1AC24710890745136F453C33@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Cloutier, Joseph (Joseph) wrote:
> I have made a fix for the "-w deadline" issue to iputils-s20101006.tar.bz2.  There are 4 places in the code with the fix, identified by my name, Joe Cloutier- ALU.
>>
>>  There are 2 bugs fixed:
>>  *       For flood pings if the "-w" option is set then more pings than "-c x" are sent out.
>>  *       The "-w x" timer should be set after he last "-c x" ping is sent out.

Is this a real bug?

If both of -c COUNT and -w TIMEOUT are specified, ping exits by
timer _OR_ by the counter regardless of -f option.

If you want to ping really COUNT times, try -W TIMEOUT option.


... And please send your changes in the patch (or unified diff;
diff -u) format with your appropriate "sign-off" line, next time.


Thanks.

--yoshfuji
