From: =?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Subject: Re: QoS hot changes changes (tc)
Date: Tue, 30 Jun 2009 08:21:34 +0200
Message-ID: <3f847c820906292321w1b85a423o2f5b25badddb9dd2@mail.gmail.com>
References: <3f847c820906260619g238b6a17ub17af3f27da83ef5@mail.gmail.com>
	 <4A469242.4070000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org >> Linux Netdev List"
	<netdev@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.152]:5266 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbZF3GVb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2009 02:21:31 -0400
Received: by fg-out-1718.google.com with SMTP id e21so1041025fga.17
        for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 23:21:34 -0700 (PDT)
In-Reply-To: <4A469242.4070000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Jarek ! I will try to test them running traffic to see how they
are doing. I miss some documentation related to these stuff :-(.

Regards,
Raul

2009/6/27 Jarek Poplawski <jarkao2@gmail.com>:
> Ra=FAl Hern=E1ndez wrote, On 06/26/2009 03:19 PM:
>
>> Hi there,
>>
>> I am trying to characterize the situation in which we perform a chan=
ge
>> in the shaping done by the Linux kernel (tc+qdisc), specifically whe=
n
>> modifying the bandwidth as a hot change while shaping with a previou=
s
>> bw value. The system I am describing performs shaping per stream
>> (uplink and/or dowinlink or total), just marking the TOS of the ip
>> packet and provisioning the kernel via 'tc' to shape the packets.
>>
>> My question is whether someone has tried to modify bw parameters, ie=
:
>> move from 90 to 45 kb/s while the queues are already being populated
>> with trafffic .Do not know if the shaper algorithm is able to adjust
>> the bw without service disruption/experiment transitory behavior as =
I
>> guess the algorithm must have some kind of feedback which depends of
>> the bytes already shaped and the value of the bw itself (ie: leaky
>> bucket).
>>
>> Any experience with this kind of changes :-) ? Thx !
>
> No experience in measuring the effects of such changes, but looking
> into code shows it depends on a shaper algorithm: tbf seems to reset
> the queue, htb doesn't.
>
> Jarek P.
>



--=20
"We cannot change the cards we are dealt, just how we play the hand.
