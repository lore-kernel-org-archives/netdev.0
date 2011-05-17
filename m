From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH V5 2/6 net-next] netdevice.h: Add zero-copy flag in netdevice
Date: Wed, 18 May 2011 00:58:00 +0200
Message-ID: <BANLkTik6aqP5BVrQNFKrnU3v=KA9ip1RoA@mail.gmail.com>
References: <1305574128.3456.23.camel@localhost.localdomain>
 <1305574518.2885.25.camel@bwh-desktop> <1305574680.3456.33.camel@localhost.localdomain>
 <1305575253.2885.28.camel@bwh-desktop> <20110516211459.GE18148@redhat.com>
 <1305588738.3456.65.camel@localhost.localdomain> <BANLkTimvOK3tyo6+L5AD=so5DjiDPV-AAA@mail.gmail.com>
 <1305671318.10756.49.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:50371 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932485Ab1EQW6V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 18:58:21 -0400
In-Reply-To: <1305671318.10756.49.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 18 maja 2011 00:28 u=BFytkownik Shirley Ma <mashirle@us.ibm.com>=
 napisa=B3:
> On Tue, 2011-05-17 at 23:48 +0200, Micha=B3 Miros=B3aw wrote:
>> 2011/5/17 Shirley Ma <mashirle@us.ibm.com>:
>> > Looks like to use a new flag requires more time/work. I am thinkin=
g
>> > whether we can just use HIGHDMA flag to enable zero-copy in macvta=
p
>> to
>> > avoid the new flag for now since mavctap uses real NICs as lower
>> device?
>>
>> Is there any other restriction besides requiring driver to not recyc=
le
>> the skb? Are there any drivers that recycle TX skbs?
> Not more other restrictions, skb clone is OK. pskb_expand_head() look=
s
> OK to me from code review.

> Currently there is no drivers recycle TX skbs.

So why do you require the target device to have some flags at all?

Do I understand correctly, that this zero-copy feature is about
packets received from VMs?

Best Regards,
Micha=B3 Miros=B3aw
