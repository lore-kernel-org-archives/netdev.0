From: Peter Bieringer <pb@bieringer.de>
Subject: Re: locked up 4-port Intel NIC with RH 8.0 and eepro100 driver
Date: Wed, 26 Feb 2003 07:42:51 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <192080000.1046241771@gate.muc.bieringer.de>
References: <3E5BE34E.4030500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>, eepro list <eepro100@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
In-Reply-To: <3E5BE34E.4030500@candelatech.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



--On Tuesday, February 25, 2003 01:42:38 PM -0800 Ben Greear
<greearb@candelatech.com> wrote:

> Seems transmit no longer works out of the second interface...
> Only the first two ports have a cable attached,
> each to a tg3 GigE NIC with a cross-over cable.  It ran for
> about 3 days at 50Mbps bi-directional on two ports before locking
> up.  The machine was at 100% CPU utilization this entire time.  After
> stopping traffic for 1 minute, and then starting it again, it started
> working again.  The error I was seeing indicated trying to write to the
> socket would block (EAGAIN).  For what it's worth, I saw similar problems
> on this machine with an rtl8139too when connected to a 10bt hub, but in
> that case the rtldiag showed more problems, and lockups happened in 3-8
> hours...

Did it work again after reloading the module?

I have also found such lockups on a Toshiba laptop with Intel chip
on-board, but mostly after some minute.

I'm not sure, but because also the wake-on-lan feature in RHL's eepro100
driver is broken, too (see here for more:
http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=84695 ), I think that
the by delivered delivered driver isn't as stable as it should be (perhaps
they didn't use the newest sources). Have you tried "e100" driver
(unfortunatly needs kernel recompiling, but here e.g. wake-on-lan is
working well).

        Peter
-- 
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D               mailto: pb at bieringer dot de 
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
