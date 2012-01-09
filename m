From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: "-w deadline" bug in ping/iputils- i will provide fix if you
 can tell me where owner of iputils is. Thanks.
Date: Tue, 10 Jan 2012 00:45:09 +0900
Message-ID: <4F0B0B85.5040305@linux-ipv6.org>
References: <7D3B6706FA74174B8C1AC24710890745136F3C8944@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: 'Linus Torvalds' <torvalds@linux-foundation.org>,
	"'netdev@vger.kernel.org'" <netdev@vger.kernel.org>,
	"'torvalds@osdl.org'" <torvalds@osdl.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: "Cloutier, Joseph (Joseph)" <joseph.cloutier@alcatel-lucent.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:46219 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755679Ab2AIPpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2012 10:45:16 -0500
In-Reply-To: <7D3B6706FA74174B8C1AC24710890745136F3C8944@USNAVSXCHMBSA1.ndc.alcatel-lucent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cloutier, Joseph (Joseph) wrote:
>
>
> -----Original Message-----
> From: Cloutier, Joseph (Joseph)
> Sent: Wednesday, January 04, 2012 3:55 PM
> To: 'Linus Torvalds'; 'netdev@vger.kernel.org'
> Cc: 'torvalds@osdl.org'
> Subject: RE: "-w deadline" bug in ping/iputils- i will provide fix if
> you can tell me where owner of iputils is. Thanks.
>
>
> netdev@vger.kernel.org.
>
> I have made a fix for the "-w deadline" issue to iputils-s20101006.tar.bz2.  There are 4 places in the code with the fix, identified by my name, Joe Cloutier- ALU.
>
> There are 2 bugs fixed:
> *       For flood pings if the "-w" option is set then more pings than "-c x" are sent out.
> *       The "-w x" timer should be set after he last "-c x" ping is sent out.
>
> Linux flood ping is an invaluable tool for us to use when trouble shooting wireless network problems.  It is a very fast way to verify things like PVC allocations, duplex miss-matches, fiber problems, egress queue settins, etc.
>
> I have modified 2 ping versions (one an older one prior to the shared library change many years ago, and then Redhat 8.0 release), but my Management does not my copies released to our Customers because the code is "unsupported".
>
> If you would accept these changes then I can direct our Customers to use the official Linux flood ping option.
>
> I have tested the code using Linux release 14 and the latest gcc compiler.  It is doing what it should now.
>
> Thanks, Joe Cloutier
>
> Created with tar cjvf ...

I could not find any patches/tarballs unfortunately.
Would you resend it please?  Thank you.

--yoshfuji
