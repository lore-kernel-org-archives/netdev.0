From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 4942 recommendation
Date: Sat, 5 Nov 2011 01:39:52 -0700 (PDT)
Message-ID: <1320482392.98040.YahooMailNeo@web126003.mail.ne1.yahoo.com>
References: <1320417988.69298.YahooMailNeo@web126013.mail.ne1.yahoo.com> <1320423860.16609.4.camel@edumazet-laptop>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm18-vm1.bullet.mail.ne1.yahoo.com ([98.138.91.64]:36314 "HELO
	nm18-vm1.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750920Ab1KEIqY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 04:46:24 -0400
In-Reply-To: <1320423860.16609.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From: Eric Dumazet <eric.dumazet@gmail.com>
>To: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
>Sent: Friday, November 4, 2011 5:24 PM
>Subject: Re: [RFC] The Linux kernel IPv6 stack don't follow the RFC 49=
42 recommendation
>
>Le vendredi 04 novembre 2011 =E0 07:46 -0700, Fran=E7ois-Xavier Le Bai=
l a
>=E9crit :
>> I do some tests on a Linux 3.0 kernel with IPv6 forwarding mode enab=
led.
>>=20
>> When I ping (ICMPv6 echo request) on one of its Subnet-Router anycas=
t addresses
>> (SRAA, http://tools.ietf.org/html/rfc4291#section-2.6.1),
>> the Linux kernel reply with an unicast source address, not the anyca=
st one.
>>=20
>> When I send an IPv6 UDP packet to a server on Linux on one of its SR=
AA,
>> the Linux kernel build a reply with an unicast source address, not t=
he anycast one.


Thanks for your answer.

>Nothing in the kernel builds a reply to an UDP packet.

You are right. I meant that in some cases the kernel selects the source=
 address
of the reply.

>I would say the user application is responsible to build an answer, an=
d
>chose appropriate source address.


OK.


>If your application uses a ANY_ADDR bind, then it must appropriate
>action so that a good source address is used in answers.
>
>In case of IPv6 socket, I advise you take a look at IPV6_PKTINFO /
>IPV6_RECVPKTINFO options.


I will study and test these options for my application server.

>> The RFC 4942 states (http://tools.ietf.org/html/rfc4942#section-2.1.=
6) :
>> 2.1.6. Anycast Traffic Identification and Security
>> [. . .]
>>=A0 =A0 To avoid exposing knowledge about the internal structure of t=
he
>>=A0 =A0 network, it is recommended that anycast servers now take adva=
ntage of
>>=A0 =A0 the ability to return responses with the anycast address as t=
he
>>=A0 =A0 source address if possible.
>>=20
>> Also, If the source address of reply differs from destination addres=
s of the request, many applications are broken.
>> Please let me know your feedback.
>>=20
>
>'anycast servers' are a combination of kernel and userland parts.


Agreed, but remain the case of ICMPv6 echo request/reply, which I think=
 is in kernel.

=46rancois-Xavier
