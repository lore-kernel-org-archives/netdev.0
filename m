From: Scott Feldman <sfeldma@pobox.com>
Subject: Re: Allow IP header alignment to be overriden
Date: Fri, 11 Jun 2004 00:39:22 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086939562.3657.10.camel@sfeldma-mobl2.dsl-verizon.net>
References: <20040611012727.GA27672@krispykreme>
	 <20040610223549.5e9ad025.davem@redhat.com>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040610223549.5e9ad025.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-06-10 at 22:35, David S. Miller wrote:
> This transformation is not valid for a lot of drivers, that "2"
> in the reserve exists elsewhere in other calculations in the
> drivers.  For example, it is added to the RX skb allocation
> size.  Sometimes this '2' is there in non-trivial or hard to
> see ways (ie. it's implicitly in some DMA alignment value)

Would replacing "2" with a macro that's defined on a per-arch basis
work?  
