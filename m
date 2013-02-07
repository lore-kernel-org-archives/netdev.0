From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Fri, 08 Feb 2013 00:41:12 +0900
Message-ID: <5113CB18.1080300@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <20130206130739.GA1305@eerihug-hybrid.ki.sw.ericsson.se> <20130206134950.GD10290@order.stressinduktion.org> <51127781.2000504@linux-ipv6.org> <20130206160409.GB18040@order.stressinduktion.org> <51128985.2010701@linux-ipv6.org> <20130207010010.GD19537@order.stressinduktion.org> <20130207072857.GA27969@eerihug-hybrid.ki.sw.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Erik Hugne <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45000 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753869Ab3BGPlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 10:41:20 -0500
In-Reply-To: <20130207072857.GA27969@eerihug-hybrid.ki.sw.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Erik Hugne wrote:
> On Thu, Feb 07, 2013 at 02:00:10AM +0100, Hannes Frederic Sowa wrote:
>> RFC4541 3. IPv6 Considerations:
>>
>>    MLD messages are also not sent regarding groups with addresses in the
>>    range FF00::/15 (which encompasses both the reserved FF00::/16 and
>>    node-local FF01::/16 IPv6 address spaces).  These addresses should
>>    never appear in packets on the link.
>>
>> It gives a strong indication that we should drop these packets. What do you
>> think?
> 
> That was my understanding aswell. I asked for some clarifications on the ietf list:
>     <quote>
>     > The key is that the packets should be dropped without generating
>     > any errors or traffic.
>     Yep, you are right - I assumed that implicitly, but
>     I should have mentioned that explicitly :-)
>     </quote>
> http://www.ietf.org/mail-archive/web/ipv6/current/msg17126.html

Please file errata on RFC4291.  Thanks.

--yoshfuji
