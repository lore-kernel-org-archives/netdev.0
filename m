From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] trivial patch for if_indextoname()
Date: Wed, 26 May 2004 15:17:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040526151751.73752ea2.davem@redhat.com>
References: <OFD3BD5C6F.D104319A-ON88256EA0.00798187-88256EA0.007A2D7C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFD3BD5C6F.D104319A-ON88256EA0.00798187-88256EA0.007A2D7C@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 26 May 2004 16:15:07 -0600
David Stevens <dlstevens@us.ibm.com> wrote:

> RFC3493 (section 4.2) specifies that an invalid interface name
> passed to if_indextoname() should return NULL with errno of ENXIO.
> The current code sets errno to ENODEV for this case.
> 
> This could be remapped in glibc, but since the comment for
> kernel function dev_ifname() says it's specifically for
> if_indextoname(), maybe it should be fixed here.

How is the SIOCGIFNAME interface specified in this case?
(ie. what does BSD do?)  I bet a bunch of stuff will
break if we change this.
