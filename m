From: Vinod <geekvinod@yahoo.com>
Subject: Re: making routes permanent
Date: Sun, 28 Apr 2002 19:08:48 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020429020848.54267.qmail@web21102.mail.yahoo.com>
References: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
In-Reply-To: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
List-Id: netdev.vger.kernel.org

where should i put the command 
any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
u suggested?shdnt it be some specific place where i
put this line?i can just add the route.thats not the
problem.i want to make it permanent.it shd stay after
rebooting.
Thanks,
Vinod
--- Glynn Clements <glynn.clements@virgin.net> wrote:
> 
> Vinod wrote:
> 
> > how can one make route's permanent?
> > i wanted to make this permanent:
> > route add -net 10.0.3.0 netmaks 255.255.255.0 gw
> > 10.0.0.10 dev eth1
> > 
> > i tried putting this in
> /etc/sysconfig/static-routes
> > but it didnt work.
> > i have rh7.2 installed.
> 
> I don't know about RH7.x, but for RH6.2 you would
> use the line:
> 
> any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
> 
> If it's different on 7.x, you can deduce the format
> from the network
> startup script (e.g. /etc/rc.d/init.d/network).
> 
> Note that specifying both "gw" and "dev" is
> redundant. If you specify
> a gateway, the device is automatically determined
> from the gateway
> address.
> 
> -- 
> Glynn Clements <glynn.clements@virgin.net>


__________________________________________________
Do You Yahoo!?
Yahoo! Health - your guide to health and wellness
http://health.yahoo.com
