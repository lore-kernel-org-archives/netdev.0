From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 2.5.70+] tun using alloc_netdev
Date: Wed, 11 Jun 2003 20:57:21 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030611.205721.115935520.davem@redhat.com>
References: <20030609115857.38bb31d6.shemminger@osdl.org>
	<5.1.0.14.2.20030611121155.0b659e20@unixmail.qualcomm.com>
	<20030611194317.GE31051@gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qualcomm.com, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
In-Reply-To: <20030611194317.GE31051@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Jeff Garzik <jgarzik@pobox.com>
   Date: Wed, 11 Jun 2003 15:43:18 -0400

   On Wed, Jun 11, 2003 at 12:21:44PM -0700, Max Krasnyansky wrote:
   > This is wrong. register_netdevice() does not expand name (ie %d stuff).
   > So dev_alloc_name() is still needed. i.e.
   
   Correct.
   
   But, register_netdev() is preferred precisely for this reason.
   
Right.
