From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.72] use alloc_netdev in bonding driver
Date: Wed, 18 Jun 2003 16:30:57 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030618.163057.74745635.davem@redhat.com>
References: <20030617113510.5ae6a5a9.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ctindel@users.sourceforge.net, fubar@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030617113510.5ae6a5a9.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 17 Jun 2003 11:35:10 -0700

   This patch replaces the allocation of an array of bonding device
   structures with allocating net_device's through alloc_netdev.  The
   net_device, statistics, and net_device are created with one
   allocation via alloc_netdev.

Applied, thanks Stephen.
