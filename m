From: "David S. Miller" <davem@redhat.com>
Subject: Re: Allow IP header alignment to be overriden
Date: Thu, 10 Jun 2004 22:35:49 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040610223549.5e9ad025.davem@redhat.com>
References: <20040611012727.GA27672@krispykreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Anton Blanchard <anton@samba.org>
In-Reply-To: <20040611012727.GA27672@krispykreme>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 11 Jun 2004 11:27:27 +1000
Anton Blanchard <anton@samba.org> wrote:

> The following patch creates skb_align and allows an architecture to
> override it. Thoughts?

This transformation is not valid for a lot of drivers, that "2"
in the reserve exists elsewhere in other calculations in the
drivers.  For example, it is added to the RX skb allocation
size.  Sometimes this '2' is there in non-trivial or hard to
see ways (ie. it's implicitly in some DMA alignment value)

That's the only reason I'm against this patch.
