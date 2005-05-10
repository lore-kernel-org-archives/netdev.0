From: Grant Grundler <iod00d@hp.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 16:21:32 -0700
Message-ID: <20050510232132.GZ5495@esmail.cup.hp.com>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11> <1115743966.8570.26.camel@rh4> <20050510.121214.39158393.davem@davemloft.net> <42813205.1040709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, Grant Grundler <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rick Jones <rick.jones2@hp.com>
Content-Disposition: inline
In-Reply-To: <42813205.1040709@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 10, 2005 at 03:13:25PM -0700, Rick Jones wrote:
> David S. Miller wrote:
> >We really should be disconnecting at single cacheline boundaries
> >on RISC systems.  The PCI controllers on RISC machines are
> >going to disconnect the tg3 when it crosses a cache line
> >boundary, so all these setting do is waste PCI bandwidth.
> 
> It is my understanding that PA-RISC and IA64 controllers behave 
> differently. For confirmation one way or the other, I've cc'd someone who 
> could talk about it much more cogently than I.

Yup, thanks rick.

Dave,
HP PCI bus controllers don't disconnect after a cacheline.
The latest "LBA" (aka Mercury) will disconnect on 4k page
boundaries. Alex Williamson confirmed.

Has anyone confirmed PPC, PPC64 and Alpha PCI/PCI-X bus
controllers do the same?

ISTR MMRBC (PCI-X only) allows one to specify
shorter blocks. I'd have to look that up again.

thanks,
grant
