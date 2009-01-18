From: Sitsofe Wheeler <sitsofe@yahoo.com>
Subject: Re: [atl2] warn_slowpath in dev_watchdog
Date: Sun, 18 Jan 2009 02:18:33 -0800 (PST)
Message-ID: <767752.95325.qm@web110601.mail.gq1.yahoo.com>
References: <gkt97e$ti0$1@ger.gmane.org> <20090117194045.649f55a0@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, Chris Snook <csnook@redhat.com>,
	jie.yang@atheros.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933296AbZARKSq@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,


> From: Jay Cliburn <jcliburn@gmail.com>
> 
> On Sat, 17 Jan 2009 18:49:18 +0000 (UTC)
> Sitsofe Wheeler wrote:
> 
> > On an ever so slightly modified 2.6.28. I think this only happens
> > when the upstream router/switch goes out to lunch and packets are
> > being sent. It is reproducible but only appears on a home network...
> > 
> > [  204.704065] ------------[ cut here ]------------
> > [  204.704074] WARNING: at net/sched/sch_generic.c:226 dev_watchdog
> > +0x22b/0x240()
> > [  204.704080] NETDEV WATCHDOG: eth0 (atl2): transmit timed out
> 
> Please provide your complete dmesg output.

Unfortunately I only saved that snippet of the log (I can provide you a full dmesg but it won't be
from a run where this problem occured).
 
> Can you briefly describe the device immediately upstream of the system producing
> the warning?

I believe it is a USRobotics ADSL modem (nmap reckons its a SureConnect 9105 but I have no means of checking as I don't have physical access to the box where it is contained). Every now and again this thing seems to buckle under network load and goes out to lunch. When this happens ethtool reports that the line has dropped and sometimes this warning appears...



      
