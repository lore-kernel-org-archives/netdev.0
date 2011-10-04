From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [RFC] iproute2: add br command
Date: Wed, 5 Oct 2011 00:32:31 +0200
Message-ID: <CAHXqBF+gXg=EAOm4F_qGWhND6EsZHzoamE8fRX6eqe1p1zU-SQ@mail.gmail.com>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
 <20111004093413.2f6bbd67@nehalam.linuxnetplumber.net> <m27h4klmls.fsf@firstfloor.org>
 <20111004140754.0e677941@nehalam.linuxnetplumber.net> <1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Andi Kleen <andi@firstfloor.org>,
	Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:60969 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933180Ab1JDWcv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 18:32:51 -0400
Received: by iakk32 with SMTP id k32so1082284iak.19
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2011 15:32:51 -0700 (PDT)
In-Reply-To: <1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/5 Sridhar Samudrala <sri@us.ibm.com>:
> On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger wrote:
>> On Tue, 04 Oct 2011 09:58:55 -0700
>> Andi Kleen <andi@firstfloor.org> wrote:
>> > Stephen Hemminger <shemminger@vyatta.com> writes:
>> > > This adds a new 'br' command which is the bridging equivalent of
>> > > the ip command. More of a demo of how to use netlink and bridgin=
g
>> > > at this point.
>> > Please name it "bridge", not "br"
>> Ok, but it breaks the existing pattern.
> Is this supposed to replace brctl utility?
>
> Can we add/delete a bridge and add/delete interfaces to a bridge usin=
g
> this command?
>
> If so, why not make it
> =C2=A0 ip bridge add/del <brname>
> =C2=A0 ip bridge addif/delif <brname> <ifname>

I'll add one more idea:

ip link add/del <brname> type bridge
ip bridge add/del <brname> <ifname>
ip bridge fdb ...

Best Regards,
Micha=C5=82 Miros=C5=82aw
