From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Wed, 11 Jun 2003 20:59:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.205943.48506382.davem@redhat.com>
References: <5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
	<20030611194317.GE31051@gtf.org>
	<20030611132715.76a485c7.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, maxk@qualcomm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030611132715.76a485c7.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Wed, 11 Jun 2003 13:27:15 -0700

   > But, register_netdev() is preferred precisely for this reason.
   
   Not possible in this case because device is created off socket
   ioctl so it is called with rtnl_lock
   
So do it by hand.
