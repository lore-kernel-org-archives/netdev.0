From: Yan-Fa Li <yanfali@yahoo.com>
Subject: SMP Re-ordering ?
Date: Thu, 18 Apr 2002 19:10:31 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020419021031.24839.qmail@web13003.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

So I've read the excellent "Beyond Softnet" paper about
how SMP is inherently likely to re-order packet flows,
and I'm trying to use the work around where I assign
IRQs to CPUs, in this case for a gigabit network
card.

I have dual PIIIs 1GHz on serverworks chipsets.  I'm using the
DGE550 66MHz/64bit GigE cards over copper.  Each system has
1.5Gbytes of RAM.  Each kernel is 2.4.19-pre5aa1 and /dev/epoll.

To force IRQ affinity to CPU 2 or 2, I type the following:

echo 2 > /proc/irq/23/smp_affinity

when I send traffic to this interface I only see
IRQs on the second CPU on /proc/interrupts.  All
is good so far.

However, a network device I'm testing between my hosts
keeps seeing re-ordered TCP sessions.  When I reboot and
specify maxcpus=1 and re-run the test I get none.

Am I doing something really wrong here or does this
workaround no longer work ?

Thanks

Yan

__________________________________________________
Do You Yahoo!?
Yahoo! Tax Center - online filing with TurboTax
http://taxes.yahoo.com/
