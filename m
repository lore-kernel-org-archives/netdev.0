From: kuznet@ms2.inr.ac.ru
Subject: Re: netlink sockets and rtm_newlink messages
Date: Mon, 30 Sep 2002 19:43:05 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209301543.TAA15388@sex.inr.ac.ru>
References: <Pine.GSO.4.30.0209291105410.8253-100000@shell.cyberus.ca>
Mime-Version: 1.0
Cc: mcmanus@ducksong.COM, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca (jamal)
In-Reply-To: <Pine.GSO.4.30.0209291105410.8253-100000@shell.cyberus.ca> from "jamal" at Sep 29, 2 11:09:10 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> So that you dont forget, heres the patch:

Thanks. Indeed, you ar right, I have already forgotten this. :-)

> Wouldnt that spot be the best for NETDEV_UP/DOWN since thats the notifier
> callback?

It was moved out of there to support ifa_change bits. But apparently
I have made copy instead of move.

> Also, can you remind me what if_change was for? netcarrier events?

ifa_change was for unimplemented control part to allow atomic changes
of state not affecting another flags.

Someone spotted that it would be convenient to have this flag set
valid in all the kinds of RTM_NEWLINK messages.

Alexey
