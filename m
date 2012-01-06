From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] net_sched: red: split red_parms into parms and vars
Date: Fri, 6 Jan 2012 09:31:47 +0100
Message-ID: <CAA93jw5618hw7=A-=ckUYkSebEDvtT0P4smYF4ay+7tMOjSqbA@mail.gmail.com>
References: <1325766316.2415.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<CAA93jw4ndMg-4BnhmspxgcXYdozu5+YX9VJgtHJ3N5HVX1b4yg@mail.gmail.com>
	<1325770777.2415.35.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325828822.2748.27.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39894 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468Ab2AFIbr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2012 03:31:47 -0500
Received: by iaeh11 with SMTP id h11so2285398iae.19
        for <netdev@vger.kernel.org>; Fri, 06 Jan 2012 00:31:47 -0800 (PST)
In-Reply-To: <1325828822.2748.27.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 6, 2012 at 6:47 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 05 janvier 2012 =E0 14:39 +0100, Eric Dumazet a =E9crit :
>
>> Problems of RED are :
>>
>> 1) the 'average' on highly variable trafic : It means nothing
>> interesting at all.
>>
>> 2) the idle time management requires to specify the link bandwidth, =
as a
>> fixed value. This is a problem.
>
> A third problem is that ECN marking is performed on the packet we add=
 to
> the tail of the queue. It's very late...
>
> I am currently testing my SFQRED and I try to add ECN in the first
> packet in queue so that TCP can react faster.

If you are in particular looking for stuff worth marking, vs dropping..=
=2E
you could even look deeper in the queue (group) than the first packet.

I am reminded somewhat of how david mills handled the first
NSFnet congestion collapse on the fuzzball.

http://osdir.com/ml/culture.internet.history/2004-12/msg00003.html

"When a new packet arrived and no buffer space was available, the
output queues were scanned looking for the biggest elephant (total
byte count on all queues from the same IP address) and killed its
biggest packet. Gunshots continued until either the arriving packet
got shot or there was enough room to save it. It all worked
gangbusters and the poor ftpers never found out. "

>
>
>



--=20
Dave T=E4ht
SKYPE: davetaht
US Tel: 1-239-829-5608
=46R Tel: 0638645374
http://www.bufferbloat.net
