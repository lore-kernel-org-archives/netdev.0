From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Mon, 15 Nov 2004 21:46:02 +0100
Message-ID: <200411152146.02851.bdschuym@pandora.be>
References: <20041115122046.1413527e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
In-Reply-To: <20041115122046.1413527e.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Date: Mon, 15 Nov 2004 04:33:51 -0800
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
>
> -s SO:ME:MA:CA:DD:R0 -j DROP
> -d SO:ME:MA:CA:DD:R0 -j DROP
> [... about 50 of them ...]
> -j RETURN
>
> It works fine. About twenty or thirty times a day, a script does 'iptables
> -F BLOCKED' and writes new entries into chain BLOCKED. Problem is that
> machine dies from time to time (under heavy network load it happens once a
> day). It just locks, nothing happenes, no oopses, or entries in logs. Then
> after 60 seconds, watchdog from Intel motherboard resets machine.
>
> Also I was doing some changes manually into chains and noticed that machine
> died after I have issued 'ebtables -F BLOCKED' (clearing the chain). Once
> again after 60 seconds watchdog reset machine.
>
> Problem is present in 2.6.8.1 and 2.6.9 kernels. There was no such problem
> on 2.4.26.

Can you do something similar with iptables rules to see if it's specific to 
ebtables (which I doubt)?

> The only weird thing I noticed is when I initalise my bridge, is something
> about that it can't get speed of some interfaces (guessing it is about
> e1000). I can't give you full error message at the moment, because those
> have been rotated by logrotate.

I don't know what that is about...

cheers,
Bart
