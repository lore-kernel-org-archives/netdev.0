From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] alloc_netdev for shaper
Date: Mon, 16 Jun 2003 14:24:07 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030616.142407.123998330.davem@redhat.com>
References: <20030616141148.72df9830.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030616141148.72df9830.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Mon, 16 Jun 2003 14:11:48 -0700

   This converts shaper to allocating an array of pointers to
   net_device's rather than an array of net_devices.  This is
   necessary because in future, network_device's may live past
   unregister
   
   Tested with shapecfg to run e1000 at 64kbps.

Applied, thanks.
