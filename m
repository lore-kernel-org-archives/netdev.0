From: Stephen Clark <sclark46@earthlink.net>
Subject: Re: Linux vs FreeBSD Which is correct.
Date: Fri, 19 Aug 2011 15:10:14 -0400
Message-ID: <4E4EB516.40102@earthlink.net>
References: <4E4BF456.9000807@earthlink.net> <201108172017.48683.remi@remlab.net> <4E4C1A00.80207@earthlink.net> <4E4C2178.1000809@plouf.fr.eu.org> <4E4D08B8.8020309@earthlink.net> <4E4E8CEE.102@genband.com>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pascal Hambourg <pascal@plouf.fr.eu.org>,
	=?ISO-8859-1?Q?R=E9mi_Den?= =?ISO-8859-1?Q?is-Courmont?=
	<remi@remlab.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-galgo.atl.sa.earthlink.net ([209.86.89.61]:54295 "EHLO
	elasmtp-galgo.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755426Ab1HSTKV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 15:10:21 -0400
In-Reply-To: <4E4E8CEE.102@genband.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2011 12:18 PM, Chris Friesen wrote:
> On 08/18/2011 06:42 AM, Stephen Clark wrote:
>
>> I guess I don't really understand what reverse path filter stuff is all
>> about, much less making it weaker.
>> But using 2 made the pings responses be seen.
>
> It's described in RFC3704.  The idea is to block spoofed packets.
>
> From Documentation/networking/ip-sysctl.txt:
>
> rp_filter - INTEGER
> 0 - No source validation.
> 1 - Strict mode as defined in RFC3704 Strict Reverse Path
>     Each incoming packet is tested against the FIB and if the interface
>     is not the best reverse path the packet check will fail.
>     By default failed packets are discarded.
> 2 - Loose mode as defined in RFC3704 Loose Reverse Path
>     Each incoming packet's source address is also tested against the FIB
>     and if the source address is not reachable via any interface
>     the packet check will fail.
>
>    Current recommended practice in RFC3704 is to enable strict mode
>    to prevent IP spoofing from DDos attacks. If using asymmetric routing
>    or other complicated routing, then loose mode is recommended.
>
>    The max value from conf/{all,interface}/rp_filter is used
>    when doing source validation on the {interface}.
>
>    Default value is 0. Note that some distributions enable it
>    in startup scripts.
>
>
>
Thanks for taking the time to explain this. Much appreciated.


-- 

"They that give up essential liberty to obtain temporary safety,
deserve neither liberty nor safety."  (Ben Franklin)

"The course of history shows that as a government grows, liberty
decreases."  (Thomas Jefferson)



