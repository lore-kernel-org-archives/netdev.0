From: Vinod <geekvinod@yahoo.com>
Subject: Re: making routes permanent
Date: Mon, 29 Apr 2002 12:41:19 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020429194119.51193.qmail@web21109.mail.yahoo.com>
References: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Glynn Clements <glynn.clements@virgin.net>
In-Reply-To: <15564.28280.676012.601803@cerise.nosuchdomain.co.uk>
List-Id: netdev.vger.kernel.org

i tried putting 
any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
in my /etc/sysconfig/static-routes but still it didnt
show up as a permanent route.i looked at the
/etc/rc.d/inet.d/network script and as far as i could
interpret(am a relative newbie),this was supposed to
be the format for my RH 7.2.
can anyone using rh7.2  confirm that "any net 10.0.3.0
255.255.255.0 gw 10.0.0.10" is what needs to be put in
/etc/sysconfig/static-routes to make this entry
permanent?
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
