From: Glynn Clements <glynn.clements@virgin.net>
Subject: Re: making routes permanent
Date: Mon, 29 Apr 2002 21:01:42 +0100
Sender: linux-net-owner@vger.kernel.org
Message-ID: <15565.42662.642870.739209@cerise.nosuchdomain.co.uk>
References: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
	<20020429194119.51193.qmail@web21109.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Vinod <geekvinod@yahoo.com>
In-Reply-To: <20020429194119.51193.qmail@web21109.mail.yahoo.com>
List-Id: netdev.vger.kernel.org


Vinod wrote:

> i tried putting 
> any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
> in my /etc/sysconfig/static-routes but still it didnt
> show up as a permanent route.

Did you restart the networking? That file is only read when networking
is started or a new interface is enabled.

Note: the easiest way to restart the networking is a reboot; the next
easiest is switching to single-user mode ("telinit 1") then switching
back to multi-user mode ("telinit 3", or "telinit 5" if you also want
X).

Just running "/etc/rc.d/init.d/network restart" probably won't work
right, is it will typically interfere with networking daemons.

-- 
Glynn Clements <glynn.clements@virgin.net>
