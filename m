From: Hasso Tepper <hasso@estpak.ee>
Subject: Re: /proc/sys/net/ipv[46]/conf/ issue unsolved
Date: Tue, 13 Feb 2007 22:29:57 +0200
Message-ID: <200702132229.58111.hasso@estpak.ee>
References: <200702131529.04708.hasso@estpak.ee> <9c46321e0702131149j4b9b642cvfe397d5bd2a30038@mail.gmail.com> <20070213201006.GG25362@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Hugo Santos <hugosantos@gmail.com>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hax.kala.ee ([194.126.124.39]:39435 "HELO hax.kala.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751036AbXBMUaI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 15:30:08 -0500
In-Reply-To: <20070213201006.GG25362@hmsreliant.homelinux.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neil Horman wrote:
> 5) the ifup $DEVICE from (4) goes through the network interface bring up
> process, and consequently sends the ioctl SIOCSIFFLAGS to the kernel, setting
> the IFF_UP flag on the appropriate interface, kicking of whatever default
> processes need to be as defined by the settings found in
> /proc/sys/net/conf/<interface>/*

... which is created _only_ if address of specific address familiy exists
already. If address is obtained via IPv6 autoconf (very common case for
IPv6 hosts) or via IPv4/IPv6 DHCP with netlink aware mechanism (also very
common nowadays - network manager) you don't have any addresses on interface
at this point therefore /proc/sys/net/ipv[46]/conf/<interface>/ are NOT
created. That's the point - you can't configure anything before the first
"carrier up" event - ie. cable is plugged on.


regards,

-- 
Hasso Tepper
Elion Enterprises Ltd. [AS3249]
IP & Data Networking Expert
