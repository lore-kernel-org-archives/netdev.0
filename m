From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] Allow multiple dummy devices again
Date: Fri, 28 Nov 2003 07:04:37 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031128070437.A5765@infradead.org>
References: <20031128004445.GA2870@averell> <20031127171313.04f89baa.davem@redhat.com> <1069983202.1041.5.camel@jzny.localdomain> <20031127174012.0bab844e.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, ak@muc.de, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031127174012.0bab844e.davem@redhat.com>; from davem@redhat.com on Thu, Nov 27, 2003 at 05:40:12PM -0800
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Nov 27, 2003 at 05:40:12PM -0800, David S. Miller wrote:
> On 27 Nov 2003 20:33:22 -0500
> jamal <hadi@cyberus.ca> wrote:
> 
> > On Thu, 2003-11-27 at 20:13, David S. Miller wrote:
> > 
> > > Even though we generally frown upon module options for networking
> > > devices, I think it's wholly appropriate for this case.
> > 
> > Why not make it also a boot option?
> 
> They're one in the same these days.
> 
> If the driver is built as a module, you pass the option in with
> at modload time, else you pass it in on the kernel command line.

You'd have to use module_param for that, but it appears the driver uses
the deprectated MODULE_PARAM..
