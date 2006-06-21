From: Krzysztof Matusik <kyf@arterm.pl>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 21 Jun 2006 14:21:05 +0200
Message-ID: <200606211421.05606.kyf@arterm.pl>
References: <1150278004.26181.35.camel@localhost.localdomain> <1150815544.5270.82.camel@jzny2> <4498114F.8090700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from b162.lepiej.pl ([217.153.189.162]:46555 "EHLO b02.lepiej.pl")
	by vger.kernel.org with ESMTP id S1751519AbWFUMWZ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 08:22:25 -0400
Received: from [10.0.0.25] ([213.199.219.69])
	(authenticated bits=0)
	by b02.lepiej.pl (8.13.7/8.13.7/Debian-1) with ESMTP id k5LCLFrY012835
	(version=TLSv1/SSLv3 cipher=EXP1024-RC4-SHA bits=56 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 14:22:15 +0200
To: netdev@vger.kernel.org
In-Reply-To: <4498114F.8090700@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dnia wtorek, 20 czerwca 2006 17:16, Patrick McHardy napisa=B3:
> jamal wrote:
> > On Tue, 2006-20-06 at 03:04 +0200, Patrick McHardy wrote:
> >>It would be nice to have support for HFSC as well, which unfortunat=
ely
> >>needs to be done in the kernel since it doesn't use rate tables.
> >>What about qdiscs like SFQ (which uses the packet size in quantum
> >>calculations)? I guess it would make sense to use the wire-length
> >>there as well.
> >
> > Didnt even think of that ;->
> > Is it getting too complicated?
>
> The code wouldn't be very complicated, it just adds some overhead. If
> you do something like I described in my previous mail the overhead fo=
r
> people not using it would be an additional pointer test before readin=
g
> skb->len. I guess we could also make it a compile time option.
> I personally think this is something that really improves our quality
> of implementation, after all, its "wire" resources qdiscs are meant
> to manage.

I'd love to see this one implemented. I'm using HFSC more than a year a=
nd it=20
never provides proper QoS on ATM/ADSL links; low delays can never be ac=
hieved=20
even with significant throttling below the h/w link bandwidth.
This would help a lot regarding the amount of adsl users but on the oth=
er=20
hand- there's not many HFSC implementations in real-life I guess (users=
 seem=20
to be afraid of it's 'complexity').=20
This idea doesn't seem look dirty- is there a chance to implement it in=
 the=20
kernel and iproute?

regards
