From: Alan Robertson <alanr@unix.sh>
Subject: Resend:  SIOCGIFBRDADDR?
Date: Thu, 15 Aug 2002 09:03:09 -0600
Sender: owner-netdev@oss.sgi.com
Message-ID: <3D5BC2AD.3070905@unix.sh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Kevin Dwyer <kevin@pheared.net>
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

I sent this earlier, but I got no reply, and can't seem to find it in the 
archives.  If you reply to this, could you please copy both Kevin Dwyer and 
myself on the reply?  Many thanks!

Hi,

Some folks using the linux-ha (heartbeat) software have been running into
some network-related problems, and Alan Cox suggested that you folks could
help us out.

One of the ways you can configure linux-ha protocols is to send broadcast
packets.  In this case, our software needs to get the broadcast address from
the OS, so we can proceed.  We currently use the SIOCGIFBRDADDR ioctl to do
this for us.  This has worked pretty well for us for quite some time, but
recently some users have run into some problems.

It appears that if one configures an interface using ifconfig, then the
SIOCGIFBRDADDR ioctl works quite nicely to determine the broadcast address
of an interface.

However, if one uses the iproute2 tools to configure the interface, then it
appears that the SIOCGIFBRDADDR ioctl returns bogus results on that interface.

Is this supposed to be the case?

Is there a different method we're supposed to use instead of SIOCGIFBRDADDR?


	Thanks!

	-- Alan Robertson
	   alanr@unix.sh
	   http://linux-ha.org/
