From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] change delete bridge to work with new unregister
Date: Thu, 29 May 2003 20:02:41 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.200241.108806909.davem@redhat.com>
References: <20030529102407.3d3cfefd.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030529102407.3d3cfefd.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Thu, 29 May 2003 10:24:07 -0700

   The changes in 2.5.70 for unregister cause deleteing a bridge device to
   hang, because the last reference to the bridge was being dropped after
   calling unregister_netdev.  Doing the unregister under lock, instead
   of by holding a reference fixes that.
   
Applied, thanks.
