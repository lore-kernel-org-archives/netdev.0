From: Thomas Graf <tgraf@suug.ch>
Subject: Re: af_packet.c bug?
Date: Mon, 28 Mar 2005 22:17:38 +0200
Message-ID: <20050328201738.GG3086@postel.suug.ch>
References: <424858D4.8060604@candelatech.com> <20050328195557.GF3086@postel.suug.ch> <4248642E.40304@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <4248642E.40304@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Ben Greear <4248642E.40304@candelatech.com> 2005-03-28 12:08
> >Seems so, please adopt the size of spkt_device in struct sockaddr_pkt
> 
> you mean adapt maybe?

Of course, stupid typo. ;->

> I was also wondering why we couldn't hold a reference to the net-device
> instead of just it's ifindex when dealing with a bound raw socket.

Saving a netdevice handle in the packet socket is not a problem but
doing the same for the packet socket address seems to be non trivial.
