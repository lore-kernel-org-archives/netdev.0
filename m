From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70] e100 report link speed via if_port
Date: Thu, 29 May 2003 14:08:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.140828.78714529.davem@redhat.com>
References: <20030529104138.751a1f54.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: scott.feldman@intel.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030529104138.751a1f54.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 29 May 2003 10:41:38 -0700

   The e100 driver knows the link speed, but it is not visible through sysfs.
   Small patch to update the net_device if_port when speed is detected;
   this can then be read through /sys/class/net/eth0/if_port.
   
if_port is deprecated, use ethtool ioctls to determine the link
speed...
