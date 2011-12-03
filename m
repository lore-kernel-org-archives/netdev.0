From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: SYN attack, with FIN flag set
Date: Sat, 03 Dec 2011 10:18:29 +0200
Message-ID: <b3ae04aef6b0ce233e8e8978782d1ccc@visp.net.lb>
References: <1755dc626dee301261ef4fe4cd66fd47@visp.net.lb>
 <1322897233.2762.79.camel@edumazet-laptop>
 <1322898902.2762.81.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:48347 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752211Ab1LCISa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2011 03:18:30 -0500
In-Reply-To: <1322898902.2762.81.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 On Sat, 03 Dec 2011 08:55:02 +0100, Eric Dumazet wrote:
> Le samedi 03 d=C3=A9cembre 2011 =C3=A0 08:27 +0100, Eric Dumazet a =C3=
=A9crit :
>
>> I believe netfilter tcp conntrack considers SYN|FIN as INVALID
>>
>
> Or if you cannot afford conntracking, just do
>
> iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

 Sure i did,thanks, but i just was curious, why connection with such=20
 flags are threated as SYN.

 ---
 System administrator
 Denys Fedoryshchenko
 Virtual ISP S.A.L.
