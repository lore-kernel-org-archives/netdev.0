From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: [Bugme-new] [Bug 3747] New: HTB causes machine lockups
Date: Tue, 16 Nov 2004 00:38:06 +0100
Message-ID: <20041115233806.GC31969@postel.suug.ch>
References: <20041115122059.4cfcd213.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: alchemyx@uznam.net.pl
Content-Disposition: inline
In-Reply-To: <20041115122059.4cfcd213.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Date: Mon, 15 Nov 2004 04:46:38 -0800
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 3747] New: HTB causes machine lockups
> 
> I have some network traffic shaping rules used on a Linux box. For example I
> have hundreds of them on eth1. I am using HTB in all cases (sometimes attaching
> SFQ to HTB rules). Everything works fine, until I issue:
> 
> tc qdisc del dev eth1 root
> 
> Which causes a machine lockup. Sometimes it happens day after day, but sometimes
> once a month. There are no traces in logs, no oopses, and so on. Machine just
> freezes (you see login on your screen, but can't type anything, can't ping that
> machine, ctrl-alt-del or sysrq doesn't work). Problem was on kernels from 2.4.21
> up to 2.4.26. Haven't tried 2.4.27 and 2.6.x on that box yet.
>
> Steps to reproduce:
> Hard to tell really. You need to set up a script creating hunderds of HTB rules
> and regenerating them every (let say) 15 minutes, issuing 'tc qdisc del dev
> ethX' everytime.

Did you ever experience the same problems with other classful qdiscs such as
CBQ? Would it be possible for you to run a similar CBQ setup on a dummy device
and see if it happens as well? Is anything going on at the time of the
deadlocks like an interface going down etc.?
