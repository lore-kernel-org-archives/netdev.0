From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: Broadcom 4400 driver bm44
Date: Thu, 8 Jul 2004 16:38:53 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708133853.GA20254@ee.oulu.fi>
References: <f3ddc6d3040707112141b20720@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Hubbard <jameshubbard@gmail.com>
Content-Disposition: inline
In-Reply-To: <f3ddc6d3040707112141b20720@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Jul 07, 2004 at 02:21:49PM -0400, James Hubbard wrote:
> I have two apps (AppA and AppB) that communicate via multicast.   The
> initial discovery process allows the apps to find each other.  The
> apps send hearbeats periodically to advertise that they are on the
> network.  After a period of time,  AppB can't see AppA.   I would say
> that AppB stops seeing AppA after the initial discovery.  I say this
> If I use this command: 
> ifconfig eth0 allmulti
> AppB receives all of the multicast data and can receive data from
> AppA.  This in turn  causes a problem where standard communication via
> TCP does not function.  Pings, ssh, etc do not work. If I disable
> allmulti. All other communication works except for multicast.

Hiya

I'll try to reproduce the problem. It's entirely possible that there's 
something wrong in the multicast filter code. What would be helpful is
some sort of quick testcase that shows this problem. I tried
a minimal multicast test program (mcast.py from the python distribution)
and that worked ok. ifconfig eth1 allmulti did cause the connection
to my home box to hang, so that I can reproduce at least ;) ;) ;)
