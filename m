From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET : Introduce SIOCGSTAMPNS ioctl to get timestamps
 with nanosec resolution
Date: Thu, 08 Mar 2007 17:45:16 +0100
Message-ID: <45F03D9C.6050708@trash.net>
References: <45E5570E.7050301@free.fr> <200703081517.57539.dada1@cosmosbay.com> <45F039BF.3070309@trash.net> <200703081742.11720.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62219 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbXCHQpU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 11:45:20 -0500
In-Reply-To: <200703081742.11720.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> On Thursday 08 March 2007 17:28, Patrick McHardy wrote:
>>>--- a/include/asm-mips/sockios.h
>>>+++ b/include/asm-mips/sockios.h
>>>@@ -20,6 +20,7 @@ #define SIOCATMARK	_IOR('s', 7, int)
>>> #define SIOCSPGRP	_IOW('s', 8, pid_t)
>>> #define SIOCGPGRP	_IOR('s', 9, pid_t)
>>>
>>>-#define SIOCGSTAMP	0x8906			/* Get stamp - linux-specific */
>>>+#define SIOCGSTAMP	0x8906		/* Get stamp (timeval) */
>>>+#define SIOCGSTAMPNS	0x8907		/* Get stamp (timespec) */
>>
>>You might want to CC linux-arch or the architecture maintainers.
>>Last time I changed something in this area I got complaints
>>because it affected syscall emulation for non-Linux binaries
>>or something like that.
> 
> 
> I really dont see how this change could break syscall emulation for non-Linux 
> binaries. SIOCGSTAMP{NS} is linux specific.
> 
> Could you please give the context of your past problems ?


It was when I added the SO_SNDBUFFORCE/SO_RCVBUFFORCE setsockopt
options. IIRC the values I chose where already used differently
for non-Linux MIPS binaries.

