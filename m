From: jamal <hadi@cyberus.ca>
Subject: Re: Allow IP header alignment to be overriden
Date: 11 Jun 2004 08:41:03 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1086957663.1067.675.camel@jzny.localdomain>
References: <20040611012727.GA27672@krispykreme>
	 <20040610223549.5e9ad025.davem@redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anton Blanchard <anton@samba.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040610223549.5e9ad025.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2004-06-11 at 01:35, David S. Miller wrote:
> On Fri, 11 Jun 2004 11:27:27 +1000
> Anton Blanchard <anton@samba.org> wrote:
> 
> > The following patch creates skb_align and allows an architecture to
> > override it. Thoughts?
> 
> This transformation is not valid for a lot of drivers, that "2"
> in the reserve exists elsewhere in other calculations in the
> drivers.  For example, it is added to the RX skb allocation
> size.  Sometimes this '2' is there in non-trivial or hard to
> see ways (ie. it's implicitly in some DMA alignment value)

An interesting (annoying one) that falls into that category is
sb1250-mac.c::sbdma_align_skb()
shows up prominently in profiles

cheers,
jamal
