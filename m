From: P@draigBrady.com
Subject: e100 NAPI performance
Date: Fri, 29 Aug 2003 11:16:46 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4F280E.1020507@draigBrady.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
I didn't get any feedback on the following mail.

Also in case this patch wasn't noticed,
I think it's a no brainer to apply?
http://tardis.linux.ie/1637/sourceforge.net

cheers,
P=E1draig.

-------- Original Message --------
Subject: e100 NAPI performance
Date: Mon, 25 Aug 2003 14:12:05 +0100
From: P@draigBrady.com
To: e1000-devel@lists.sourceforge.net

Hi,

I'm testing the latest e100 driver (3.0.0_dev13)
in a device here that is purely used to
capture traffic, and I'm testing with 64 byte packets.

I've turned on NAPI and can recv up to 120K packets/s
fine. (btw the driver without NAPI is
fine up to 101K packets/s). Above this though
the packet capture rate actually decreases

At 130K packets/s only 110K/s are received,
and 16K/s are rx fifo overruns.
I thought NAPI was supposed to keep a bound
on the worst case?

any advice on improving performance
like ethtool params or something?

CPU is 1.2GHz PIII
linux kernel is 2.4.20
