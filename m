From: jamal <hadi@cyberus.ca>
Subject: Re: RFC/PATCH capture qdisc requeue event in stats
Date: 28 Sep 2004 22:31:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1096425085.1041.107.camel@jzny.localdomain>
References: <1093799632.1073.410.camel@jzny.localdomain>
	 <1096413009.27967.1.camel@localhost.localdomain>
	 <20040928161838.3d19a17d.davem@davemloft.net>
	 <1096416101.27967.10.camel@localhost.localdomain>
	 <20040928170315.760b9851.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20040928170315.760b9851.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2004-09-28 at 20:03, David S. Miller wrote:

> > 
> > Well it seems to work for me:
> > 	  kernel
> >         New	Old
> > tc New  Ok      Ok(0)
> >    Old  Ok(0)   Ok
> > 
> > Because tc correctly handles the returned TLV size.
> 
> Because tc has all the length checking stuff added to
> it, other applications using netlink might not.  The
> whole world is not 'tc'.
> 
> I'm just rehashing how the most recent thread between
> Jamal and myself ended about this topic.

Steve just kill it for now - Dave is right. I think maybe something
based out of a cleaned gnet_stats patch i posted earlier would be the
best path forward. I will try to clean it up.

cheers,
jamal
