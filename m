From: Santiago Garcia Mantinan <netdev@manty.net>
Subject: [BUG] 4 extra bytes in xirc2ps_cs driver packages
Date: Sun, 21 Nov 2004 23:25:47 +0100
Message-ID: <20041121222547.GA3794@man.manty.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi!

I don't know who can take a look at the bug in this driver, the thing is
that when I tried to use a card with xirc2ps_cs driver as part of a bridge I
saw that some of the packages comming through this driver had their length
incremented in 4 bytes.

We had a similar problem with the 8139too and the rtl8139 drivers, this time
it doesn't seem to happen on all packets I believe that it is not happening
with the small ones, I can do more tests if somebody is willing to drive me
in them and to have a look at the driver's code.

The kernel I was using when I did the tests was a 2.4.27 with pcmcia 3.2.5,
the machine where I found this internal card is a Digital pentium mmx
laptop. I don't know who is maintaining this driver, that's why I'm sending
this to the list.

I hope I can help tracking this down doing more tests, don't hesitate to
contact me.

Regards...
-- 
Manty/BestiaTester -> http://manty.net
