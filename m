From: Vinod <geekvinod@yahoo.com>
Subject: Re: making routes permanent
Date: Mon, 29 Apr 2002 13:11:24 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020429201124.43460.qmail@web21101.mail.yahoo.com>
References: <15565.42662.642870.739209@cerise.nosuchdomain.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Glynn Clements <glynn.clements@virgin.net>
In-Reply-To: <15565.42662.642870.739209@cerise.nosuchdomain.co.uk>
List-Id: netdev.vger.kernel.org

yeah i had rebooted it before reporting that it didnt
work.so i guess its not that networking wasnt
restarted.all my static-route has is this line.just
created the file static-routes a couple of days ago.
Thanks,
Vinod
--- Glynn Clements <glynn.clements@virgin.net> wrote:
> 
> Vinod wrote:
> 
> > i tried putting 
> > any net 10.0.3.0 255.255.255.0 gw 10.0.0.10
> > in my /etc/sysconfig/static-routes but still it
> didnt
> > show up as a permanent route.
> 
> Did you restart the networking? That file is only
> read when networking
> is started or a new interface is enabled.
> 
> Note: the easiest way to restart the networking is a
> reboot; the next
> easiest is switching to single-user mode ("telinit
> 1") then switching
> back to multi-user mode ("telinit 3", or "telinit 5"
> if you also want
> X).
> 
> Just running "/etc/rc.d/init.d/network restart"
> probably won't work
> right, is it will typically interfere with
> networking daemons.
> 
> -- 
> Glynn Clements <glynn.clements@virgin.net>


__________________________________________________
Do You Yahoo!?
Yahoo! Health - your guide to health and wellness
http://health.yahoo.com
