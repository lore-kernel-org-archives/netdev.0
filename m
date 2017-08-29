From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 0/4] irda: move it to drivers/staging so we can delete it
Date: Tue, 29 Aug 2017 13:28:05 +0200
Message-ID: <20170829112805.GB14571@kroah.com>
References: <20170827150334.32495-1-gregkh@linuxfoundation.org>
 <CAMuHMdUefXtqv9bFfgrkbu8NZRXeTD6qR-nErf6TCDz4L+OAWw@mail.gmail.com>
 <20170829131131.6e11c8f9@elisabeth>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        driverdevel <devel@driverdev.osuosl.org>,
        Samuel Ortiz <samuel@sortiz.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170829131131.6e11c8f9@elisabeth>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 29, 2017 at 01:11:31PM +0200, Stefano Brivio wrote:
> On Tue, 29 Aug 2017 12:59:00 +0200
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> 
> > Hi Greg,
> > 
> > On Sun, Aug 27, 2017 at 5:03 PM, Greg Kroah-Hartman
> > <gregkh@linuxfoundation.org> wrote:
> > > The IRDA code has long been obsolete and broken.  So, to keep people
> > > from trying to use it, and to prevent people from having to maintain it,
> > > let's move it to drivers/staging/ so that we can delete it entirely from
> > > the kernel in a few releases.  
> > 
> > (diving into an early boot crash)
> > 
> > Have you tried running this? ;-)
> > 
> > irda_init() and net_dev_init() are both subsys_initcall()s.
> > But the former now runs before the latter, leading to:
> > 
> > Unable to handle kernel NULL pointer dereference at virtual address 00000004
> 
> Should be fixed by https://patchwork.ozlabs.org/patch/807006/
> ("[net-next] staging: irda: force to be a kernel module") I guess...

Yup, that's the fix for this issue.

Geert, does that fix the problem for you?

thanks,

greg k-h
