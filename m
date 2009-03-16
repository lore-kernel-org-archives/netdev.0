From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PROBLEM]: potential unaligned memory access in drivers/usb/gadget/rndis.c
Date: Mon, 16 Mar 2009 01:38:32 -0700
Message-ID: <200903160138.32964.david-b@pacbell.net>
References: <3848726.1723791236775868071.JavaMail.root@spooler2-g27.priv.proxad.net> <20090311235119.f4609775.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: yann.poupet-GANU6spQydw@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090311235119.f4609775.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 11 March 2009, Andrew Morton wrote:
> 
> > It happened to me that skb_pull() returns a pointer to a
> > location not aligned on a 4 bytes boundary. 

Does this arch set NET_IP_ALIGN appropriately?

If worst comes to worst, use put_unaligned() instead of
a static (non-const) template for that header.


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
