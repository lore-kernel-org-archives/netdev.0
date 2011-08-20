From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Bridge stays down until a port is added
Date: Sat, 20 Aug 2011 11:47:12 +0200
Message-ID: <20110820094712.GC21307@torres.zugschlus.de>
References: <20110811070659.GA21307@torres.zugschlus.de>
 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
 <20110811205429.GB21307@torres.zugschlus.de>
 <alpine.DEB.2.02.1108121418090.11637@aurora>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Sven-Haegar Koch <haegar@sdinet.de>,
	Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:56481 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761Ab1HTJrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 05:47:13 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1108121418090.11637@aurora>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was a little bit confused. The problem is that with IPv6 an IP
address configured on a bridge which is still in the NO-CARRIER state
will never leave tentative state and will thus not get useable.

On Fri, Aug 12, 2011 at 02:22:27PM +0200, Sven-Haegar Koch wrote:
> For me (using kernel 3.0.0) it seems to work as I expect it:
> 
> aurora:~# brctl addbr br0
> aurora:~# ifconfig br0 192.168.254.1 netmask 255.255.255.0 up
> aurora:~# ping 192.168.254.1
> PING 192.168.254.1 (192.168.254.1) 56(84) bytes of data.
> 64 bytes from 192.168.254.1: icmp_req=1 ttl=64 time=0.087 ms

Now try it with IPv6.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
