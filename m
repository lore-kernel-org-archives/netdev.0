From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: borkage in 2.6.23-rc4-mm1
Date: Sat, 1 Sep 2007 09:08:19 -0700
Message-ID: <20070901090819.5bce4f79.akpm@linux-foundation.org>
References: <20070831211603.083dfed2.akpm@linux-foundation.org>
	<46D9352B.4060606@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <46D9352B.4060606-o2qLIJkoznsdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> On Sat, 01 Sep 2007 05:47:23 -0400 Jeff Garzik <jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org> wrote:
> Andrew Morton wrote:
> > Am seeing random crap like this:
> > 
> > Aug 31 20:57:46 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
> > Aug 31 20:57:51 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
> > Aug 31 20:57:56 sony dhclient: dhclient(4537) is already running - exiting. 
> > Aug 31 20:57:56 sony dhclient: exiting.
> > Aug 31 20:58:05 sony dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 4
> > Aug 31 20:58:07 sony kernel: ipw2200: Firmware error detected.  Restarting.
> > Aug 31 20:58:09 sony dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 7
> > Aug 31 20:58:16 sony dhclient: DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 14
> > Aug 31 20:58:16 sony dhclient: DHCPOFFER from 192.168.2.1
> > Aug 31 20:58:16 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
> > Aug 31 20:58:20 sony dhclient: DHCPREQUEST on eth1 to 255.255.255.255 port 67
> > Aug 31 20:58:20 sony dhclient: DHCPACK from 192.168.2.1
> > Aug 31 20:58:20 sony NET[4946]: /sbin/dhclient-script : updated /etc/resolv.conf
> > Aug 31 20:58:20 sony dhclient: bound to 192.168.2.5 -- renewal in 125513 seconds.
> > Aug 31 20:59:45 sony ntpd[2059]: sendto(192.36.143.234): Invalid argument
> > Aug 31 20:59:51 sony ntpd[2059]: sendto(193.225.14.163): Invalid argument
> > Aug 31 20:59:52 sony ntpd[2059]: sendto(193.60.199.78): Invalid argument
> > Aug 31 21:01:31 sony kernel: ipw2200: Firmware error detected.  Restarting.
> > Aug 31 21:01:54 sony ntpd[2059]: sendto(192.36.143.234): Invalid argument
> > Aug 31 21:01:59 sony ntpd[2059]: sendto(193.225.14.163): Invalid argument
> > Aug 31 21:02:02 sony ntpd[2059]: sendto(193.60.199.78): Invalid argument
> > Aug 31 21:04:04 sony ntpd[2059]: sendto(192.36.143.234): Invalid argument
> > Aug 31 21:04:05 sony kernel: ipw2200: Firmware error detected.  Restarting.
> > Aug 31 21:04:07 sony ntpd[2059]: sendto(193.225.14.163): Invalid argument
> > Aug 31 21:04:12 sony ntpd[2059]: sendto(193.60.199.78): Invalid argument
> > Aug 31 21:05:21 sony kernel: ipw2200: Firmware error detected.  Restarting.
> 
> I see this on my Sony Vaio with older, non-mm kernels too.  Incredibly 
> frustrating, as it seems to be related to the phase of the moon. 
> Sometimes a reboot gets my wireless working, sometimes it doesn't.
> 

I've always had heaps of firmware restarts.  It's the sendto errors which
are new (I think).
