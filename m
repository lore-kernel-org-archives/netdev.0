From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 20:40:36 +0200
Message-ID: <fba83b3d6a6e9b2568b37dca707ad98d@visp.net.lb>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
 <1322897233.2762.79.camel@edumazet-laptop>
 <1322898902.2762.81.camel@edumazet-laptop>
 <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
 <1322902401.2762.85.camel@edumazet-laptop> <4ED9E5FA.30204@msgid.tls.msk.ru>
 <73da1a18b48dc3097acd6728be208c66@visp.net.lb>
 <1322905302.2762.106.camel@edumazet-laptop>
 <1322906522.2762.108.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Tokarev <mjt@tls.msk.ru>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48701 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754103Ab1LCSkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 13:40:37 -0500
In-Reply-To: <1322906522.2762.108.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Sat, 03 Dec 2011 11:02:02 +0100, Eric Dumazet wrote:
> Le samedi 03 d=C3=A9cembre 2011 =C3=A0 10:41 +0100, Eric Dumazet a =C3=
=A9crit :
>> [PATCH] tcp: drop SYN+FIN messages
>>
>> Denys Fedoryshchenko reported that SYN+FIN attacks were bringing his
>> linux machines to their limits.
>>
>> Dont call conn_request() if the TCP flags includes SYN flag
>>
>
> Oh well this should be :
>
> Dont call conn_request() if the TCP flags includes FIN flag

 Thats what i meant, maybe this will not slow down things (there is=20
 other conditions already available, such as rst, just one more), but=20
 will be somehow helpful for network administrators, since such attack=20
 are bypassing --syn iptables flag. I hope it doesn't break anything.


 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
