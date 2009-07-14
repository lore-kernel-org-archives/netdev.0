From: Andrew Lutomirski <amluto@gmail.com>
Subject: Re: [PATCH 1/1] Tell linkwatch about new interfaces
Date: Tue, 14 Jul 2009 14:58:06 -0400
Message-ID: <cb0375e10907141158l345742e3t1a252d1d1d0db526@mail.gmail.com>
References: <cb0375e10904010840n1543a890w9039465d0f80ffcc@mail.gmail.com>
	 <20090404.170539.148727646.davem@davemloft.net>
	 <ce0170d90907141017h732c2cd7ja5990303093b6edd@mail.gmail.com>
	 <20090714.113348.155881037.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eeeesti@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756023AbZGNS6L@vger.kernel.org>
In-Reply-To: <20090714.113348.155881037.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2009 at 2:33 PM, David Miller<davem@davemloft.net> wrot=
e:
> From: Sergio Luis <eeeesti@gmail.com>
> Date: Tue, 14 Jul 2009 14:17:21 -0300
>
>> is this patch incorrect, though? with the linkwatch_fire_event() cal=
l,
>> the rfc2863 operstate will be set for everyone at device register
>> time.
>
> The issue is dumb drivers that do not manage their link state
> at all. =A0We want them to always have their links up, from the
> moment they are registered.

Such dumb drivers still end up with bogus operstate.

>
> This is especially important for virtual devices.

$ ip link show lo
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00

I've never noticed this causing a problem, but it seems a little
silly.  Presumably lo should be "UP."

--Andy

>
