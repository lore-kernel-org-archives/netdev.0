From: Glynn Clements <glynn.clements@virgin.net>
Subject: Re: making routes permanent
Date: Sun, 28 Apr 2002 22:49:44 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
References: <20020428175522.12005.qmail@web21102.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Vinod <geekvinod@yahoo.com>
In-Reply-To: <20020428175522.12005.qmail@web21102.mail.yahoo.com>
List-Id: netdev.vger.kernel.org


Vinod wrote:

> how can one make route's permanent?
> i wanted to make this permanent:
> route add -net 10.0.3.0 netmaks 255.255.255.0 gw
> 10.0.0.10 dev eth1
> 
> i tried putting this in /etc/sysconfig/static-routes
> but it didnt work.
> i have rh7.2 installed.

I don't know about RH7.x, but for RH6.2 you would use the line:

any net 10.0.3.0 255.255.255.0 gw 10.0.0.10

If it's different on 7.x, you can deduce the format from the network
startup script (e.g. /etc/rc.d/init.d/network).

Note that specifying both "gw" and "dev" is redundant. If you specify
a gateway, the device is automatically determined from the gateway
address.

-- 
Glynn Clements <glynn.clements@virgin.net>
