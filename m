From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.22-rc4-mm2 -- ipw2200 -- SIOCSIFADDR: No buffer space
 available
Date: Thu, 7 Jun 2007 13:15:59 -0700
Message-ID: <20070607131559.cd95a181.akpm@linux-foundation.org>
References: <a44ae5cd0706071125p2079472eme52821bd134d26b0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Miles Lane" <miles.lane@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50442 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752043AbXFGUQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 16:16:53 -0400
In-Reply-To: <a44ae5cd0706071125p2079472eme52821bd134d26b0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 7 Jun 2007 11:25:30 -0700
"Miles Lane" <miles.lane@gmail.com> wrote:

> Hi Andrew,
> 
> This might be some problem with my kernel configuration.
> I added:
> CONFIG_BONDING=y
> 
> # dhclient eth1
> There is already a pid file /var/run/dhclient.pid with pid 134993416
> Internet Systems Consortium DHCP Client V3.0.4
> Copyright 2004-2006 Internet Systems Consortium.
> All rights reserved.
> For info, please visit http://www.isc.org/sw/dhcp/
> SIOCSIFADDR: No buffer space available
> Listening on LPF/eth1/00:12:f0:5e:db:2f
> Sending on   LPF/eth1/00:12:f0:5e:db:2f
> Sending on   Socket/fallback
> DHCPDISCOVER on eth1 to 255.255.255.255 port 67 interval 6
> DHCPOFFER from 192.168.1.1
> DHCPREQUEST on eth1 to 255.255.255.255 port 67
> DHCPACK from 192.168.1.1
> SIOCSIFADDR: No buffer space available
> SIOCSIFNETMASK: Cannot assign requested address
> SIOCSIFBRDADDR: Cannot assign requested address
> SIOCADDRT: Network is unreachable
> bound to 192.168.1.2 -- renewal in 2993 seconds.
> 
> # ping www.yahoo.com
> ping: unknown host www.yahoo.com
> 
> Any suggestions what to try now?  I'll go ahead and turn off the
> bonding option and see if that helps.
> 

It won't be related to bonding.

It has a high probability of being very related to Herbert's changes
to inet_set_ifa().
