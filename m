From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] Tun device encapsulation
Date: Wed, 04 Jun 2003 23:50:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030604.235005.26995218.davem@redhat.com>
References: <20030604115236.309a173d.akpm@digeo.com>
	<20030604212528.GA24515@conectiva.com.br>
	<20030604154022.0ef344ff.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, jgarzik@pobox.com, akpm@digeo.com, jjs@tmsusa.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030604154022.0ef344ff.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Wed, 4 Jun 2003 15:40:22 -0700

   Tun device was encapsulating the net_device in a private structure
   then doing:

   	unregister_netdev(&tun->dev);
   	kfree(tun);
   	rtnl_unlock();
   
   This breaks with the delayed cleanup now in the network core.
   Moving the kfree outside of the rtnl_unlock will fix it.
   
   Builds, but not sure how to use TUN to test it.
   
This seems to indeed fix the problem for people, applied thanks.
