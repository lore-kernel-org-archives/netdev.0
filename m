From: bert hubert <ahu@ds9a.nl>
Subject: [debi.janos@freemail.hu: Re: 2.6.7-mm1 - 2.6.7-mm4 weird http behavior]
Date: Tue, 29 Jun 2004 21:35:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629193507.GA10872@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Netdev people, I think this thread on lkml is worthy of your attention, this
is one message in it.

The summary is that recent mm kernels cannot connect to some servers, and
that the sysctl below solves it.

----- Forwarded message from Debi Janos <debi.janos@freemail.hu> -----

Date: Tue, 29 Jun 2004 20:47:57 +0200 (CEST)
From: Debi Janos <debi.janos@freemail.hu>
Subject: Re: 2.6.7-mm1 - 2.6.7-mm4 weird http behavior
To: bert hubert <ahu@ds9a.nl>
Cc: linux-kernel@vger.kernel.org

bert hubert <ahu@ds9a.nl> ?rta:

> On Tue, Jun 29, 2004 at 08:04:46PM +0200, Debi Janos wrote:
> > bert hubert <ahu@ds9a.nl> ?rta:

> Suggestions:
> 	1) turn off timestamps (echo 0 >
/proc/sys/net/ipv4/tcp_timestamps)
> 	2) set your MTU to 1000 or so (ifconfig eth0 mtu 1000)
> 
> And try again.
> 
> Interesting case!

problem workarounded:

sysctl -w net.ipv4.tcp_moderate_rcvbuf=0
sysctl -w net.ipv4.tcp_default_win_scale=0 

Thanks.

----- End forwarded message -----

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
