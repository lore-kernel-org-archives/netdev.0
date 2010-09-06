From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Mon, 06 Sep 2010 22:44:33 +0200
Message-ID: <4C8552B1.8020806@ans.pl>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl> <1283804955.2585.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:40826 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751669Ab0IFUoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 16:44:37 -0400
In-Reply-To: <1283804955.2585.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-06 22:29, Eric Dumazet wrote:
> Le lundi 06 septembre 2010 =C3=A0 21:55 +0200, Krzysztof Ol=C4=99dzki=
 a =C3=A9crit :
>
>> Yes, conntrack is one of possibilities. However, this problem only
>> manifests on 2.6.34 and never on 2.6.31 where iptables and conntrack
>> configurations are identically. And of course, each time it is a
>> different port.
>>
>> Please also note that this problem only exists when communication is
>> handled over a loopback interface - I'm not able to trigger this fro=
m a
>> remote host even if I run the test on two hosts (local&  remote)
>> simultaneously.
>>
>
> No particular error shown in "netstat -s" ?

No... :(

Udp:
     8542243 packets received
     489605 packets to unknown port received.
     1 packet receive errors
     4254527 packets sent
     RcvbufErrors: 1

> port randomization on UDP changed in the past, and conntracking chang=
ed
> a bit too ;)

I know but AFAIR all important changs were alredy included in 2.6.31.=20
And again: there is no problem in quering DNS from a remote host:
  [client 2.6.24.6] <-ethernet-> [server 2.6.34.6]

BTW: I have been able to reproduce this problem on a different, less=20
critical host after upgrading its kernel to 2.6.34.6. Unfortunately I'm=
=20
still not able to do in on my lab environment. :( Anyway, I'll try to=20
catch "conntrack -E" output and see what conntrack thinks about such=20
packets.

Best regards,

			Krzysztof Ol=C4=99dzki
