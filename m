From: kuznet@ms2.inr.ac.ru
Subject: Re: IPv6 ND on PPC hardware
Date: Fri, 5 Jul 2002 20:05:19 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200207051605.UAA06535@sex.inr.ac.ru>
References: <20020629143901.GA1963@wonderland.linux.it>
Mime-Version: 1.0
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com, md@Linux.IT
In-Reply-To: <20020629143901.GA1963@wonderland.linux.it> from "Marco d'Itri" at Jun 29, 2 07:15:01 pm
List-Id: netdev.vger.kernel.org

Hello!

> When I try to ping another host on the LAN it usually works the first
> time, and then stops working because the other host does not replies to
> ND requests. 

It would be better if you gave full tcpdump where "working" stage
is present too.

> Apparently verything works again if I switch the interface
> in promiscuous mode.

At receiver? If yes, then it is most likely wrongly configured
multicast filter at device. Though it is still not clear why it worked
the first time.

Alexey
