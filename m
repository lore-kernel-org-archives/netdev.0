From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] PPP handling fragmented skbuff's
Date: Sat, 28 Jun 2003 00:21:29 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030628.002129.35022526.davem@redhat.com>
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
   
   Please review carefully before applying, it builds and runs but
   can't really force these code path to occur under normal systems
   and devices.

It looks ok.  But I'll let this one sit over the weekend
before applying so others can test it out.
