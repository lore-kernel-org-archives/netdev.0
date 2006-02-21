From: Ernst Herzberg <earny@net4u.de>
Subject: Re: 2.6.16-rc4 bridge/iptables Oops
Date: Tue, 21 Feb 2006 02:11:21 +0100
Message-ID: <200602210211.22364.earny@net4u.de>
References: <200602201651.50217.list-lkml@net4u.de> <43FA0C02.8000909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@lists.netfilter.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932700AbWBUBL1@vger.kernel.org>
To: linux-kernel@vger.kernel.org
In-Reply-To: <43FA0C02.8000909@trash.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 20 February 2006 19:35, Patrick McHardy wrote:
> Ernst Herzberg wrote:
> > This machine oopses one to three (or more?) times a day. Occurs since
> > upgrading from -rc3 to -rc4 (and adding/reconfiguring raid).
> >
> > It is reproducable, i have only to wait 10min to a couple of hours:-)
> >
> > Opps copy/pasted from a serial console, long lines maybe truncated.
> > dmesg is from the _previous_ boot/oops....
> >
> > -------------------------------------------
> > Oops: 0000 [#1]
> > PREEMPT
> > Modules linked in: ebt_log ebt_ip ebtable_filter ebtables nfsd exportfs
> > lockd sunrpc w83627hf hwmon_vid i2c_isa xt_tcpudp xt_state ipt_MASQUERADE
> > iptable_e CPU:    0
> > EIP:    0060:[<b033fbf3>]    Not tainted VLI
> > EFLAGS: 00010282   (2.6.16-rc4 #3)
> > EIP is at xfrm_lookup+0x1f/0x47d


> This patch should fix it. Please test it and report if it helps.

oernie:~ # uname -a ; uptime
Linux oernie 2.6.16-rc4 #1 PREEMPT Mon Feb 20 22:07:34 CET 2006 i686 Intel(R) 
Pentium(R) 4 CPU 2.80GHz GenuineIntel GNU/Linux
 02:06:00 up  3:53,  4 users,  load average: 0.08, 0.15, 0.10

No oops so far. Serial console still connected, will report if this or a 
similar problem occurs again.

Thanks!

<earn/>
