From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] PPP handling fragmented skbuff's
Date: Wed, 09 Jul 2003 19:08:38 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030709.190838.70200577.davem@redhat.com>
References: <20030627163524.347b2c8e.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org
In-Reply-To: <20030627163524.347b2c8e.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Fri, 27 Jun 2003 16:35:24 -0700

   Don't think this ever happens today, but if PPP ever gets a
   fragmented a skbuff and decides to copy it then bad things will
   happen.  The following replaces the places that memcpy() with
   skb_copy_bits().

Applied, thanks Stephen.
