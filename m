From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] post-sysfs netdev cleanup
Date: Thu, 22 May 2003 17:44:15 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030522.174415.28799441.davem@redhat.com>
References: <3ECD6E2D.5090000@rogers.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: muizelaar@rogers.com
In-Reply-To: <3ECD6E2D.5090000@rogers.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Muizelaar <muizelaar@rogers.com>
   Date: Thu, 22 May 2003 20:41:17 -0400

   The attached patch removes the struct device from struct net_device
   and sets net_device.class_dev.dev directly.
   The class_dev memset is removed because all of struct net_device
   should already be memset to 0 or there will be other problems.

Looks fine to me, Stephen?
