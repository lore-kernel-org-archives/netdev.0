From: Vinod <geekvinod@yahoo.com>
Subject: RE: making routes permanent
Date: Tue, 30 Apr 2002 12:25:05 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20020430192505.44334.qmail@web21108.mail.yahoo.com>
References: <A00147B07D14F240825D27196B05DD53069A10@zms.staff.zeelandnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Serge Maandag <serge.maandag@staff.zeelandnet.nl>
In-Reply-To: <A00147B07D14F240825D27196B05DD53069A10@zms.staff.zeelandnet.nl>
List-Id: netdev.vger.kernel.org

i had tried this also.but no luck.stuck with manually
configuring the route everytime as of now.
Thanks anyway.appreciate it.
Vinod
--- Serge Maandag <serge.maandag@staff.zeelandnet.nl>
wrote:
> >         device args
> > 
> >    When a network interface is brought up, each
> line
> > for that interface
> >     is passed to route as:
> > 
> >         route add -args device
> 
> If I read this correctly, you should try the line:
> 
> -net 10.0.3.0 netmask 255.255.255.0 gw 10.0.0.10 dev
> 
> 
> or
> 
> -net 10.0.3.0/24 gw 10.0.0.10 dev 
> 
> in your static-routes file. Have you tried that?
> 
> Serge.
> 
> b.t.w., a quick search in Google gives this page:
> http://www.physiology.wisc.edu/~cai/linux/a21p/
> 
> Which uses this form:
> 
> eth0-cln net 192.168.2.0 netmask 255.255.255.0 gw
> 192.168.2.99
> 
> which would be in your case:
> 
> eth1 net 10.0.3.0 netmask 255.255.255.0 gw 10.0.0.10
> 


__________________________________________________
Do You Yahoo!?
Yahoo! Health - your guide to health and wellness
http://health.yahoo.com
