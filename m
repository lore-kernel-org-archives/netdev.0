From: Fedor Karpelevitch <fedor@karpelevitch.net>
Subject: Re: [PATCH] Re: ifconfig up/down problem
Date: Tue, 9 Sep 2003 16:35:58 -0700
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200309091635.58748.fedor@karpelevitch.net>
References: <Pine.LNX.4.56.0309090004100.24700@space.comunit.de> <3F5CFF7E.1090005@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
	Andrew Morton <akpm@digeo.com>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>,
	Sven-Haegar Koch <haegar@sdinet.de>
In-Reply-To: <3F5CFF7E.1090005@pobox.com>
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Sven-Haegar Koch wrote:
> > hi...
> >
> > Short: ifconfig ethX down locks
> >
> > Kernel: 2.4.22-bk12 (same problem with 2.4.23-pre3)
> > eth0: eepro100
> > eth1: orinoco_cs (orinoco mini-pci)
> > System: Toshiba Satellite Pro 4600 Laptop, P3 700Mhz
> >
> > Just after booting, no X startet yet, interface not yet
> > initialized:
> >
> > aurora:~# ifconfig eth1 down
> > aurora:~# ifconfig eth1 up
> > aurora:~# ifconfig eth1 down
> > aurora:~# ifconfig eth1 up
> > aurora:~# ifconfig eth1 down
> > <--lock here, shell does not return, even ctrl-c does not help
> >
> > haegar@aurora:~$ ps axl|grep ifconfig
> > 4     0  1041  1035   9   0  1448  404 dev_cl S    pts/0     
> > 0:00 ifconfig eth1
> >
> > top shows ifconfig consuming 100% cpu, 100% system
> >
> > The same happens with eth0, there it takes only two up/down
> > cycles, perhaps because it is already configured with ipv4+ipv6
> > addresses, and the same happens using '/sbin/ip link set eth0
> > up/down' too.
> >
> > Kernel 2.4.20-pre2-ac3 is ok (my last kernel, running for month')
>
> Does the attached patch fix it?
>
> 	Jeff


does not help me (assuming I have the same problem). I have a total 
lockup a few seconds after setting up the interface (not 
immidiately).

Fedor.
