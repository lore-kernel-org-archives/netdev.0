From: Catalin BOIE <util@deuroconsult.ro>
Subject: Re: [PATCH] qdisc oops fix
Date: Thu, 17 Apr 2003 08:25:38 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.53.0304170825070.23586@hosting.rdsbv.ro>
References: <20030415084706.O1131@shell.cyberus.ca>
 <Pine.LNX.4.53.0304160838001.25861@hosting.rdsbv.ro> <20030416072952.E4013@shell.cyberus.ca>
 <3E9D755A.8060601@colorfullife.com> <20030416160606.GA32575@louise.pinerecords.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Manfred Spraul <manfred@colorfullife.com>, jamal <hadi@cyberus.ca>,
   Catalin BOIE <util@deuroconsult.ro>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomas Szepe <szepe@pinerecords.com>
In-Reply-To: <20030416160606.GA32575@louise.pinerecords.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > >>Trace; c0127e0f <kmalloc+eb/110>
> > >>Trace; c01d3cac <qdisc_create_dflt+20/bc>
> > >>Trace; d081ecc7 <END_OF_CODE+1054ff0f/????>
> > >>Trace; c01d5265 <tc_ctl_tclass+1cd/214>
> > >>Trace; d0820600 <END_OF_CODE+10551848/????>
> > >>Trace; c01d27e4 <rtnetlink_rcv+298/3bc>
> > >>Trace; c01d0605 <__neigh_event_send+89/1b4>
> > >>Trace; c01d7cd4 <netlink_data_ready+1c/60>
> > >>Trace; c01d7730 <netlink_unicast+230/278>
> > >>Trace; c01d7b73 <netlink_sendmsg+1fb/20c>
> > >>Trace; c01c79d5 <sock_sendmsg+69/88>
> > >>Trace; c01c8b48 <sys_sendmsg+18c/1e8>
> > >>Trace; c0120010 <map_user_kiobuf+8/f8>
> > >>
> > I don't understand the backtrace. Were any modules loaded? Perhaps
> > 0xd081ecc7 is a module.

Yes, is htb module. I don't know why it didn't resolved.

> The original backtrace as provided by Martin Volf does not contain
> any weird addresses such as 0xd081ecc7 above:
>
> http://marc.theaimsgroup.com/?l=linux-kernel&m=105013596721774&w=2
>
> --
> Tomas Szepe <szepe@pinerecords.com>
>

---
Catalin(ux) BOIE
catab@deuroconsult.ro
