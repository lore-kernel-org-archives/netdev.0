From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Thu, 26 Jun 2008 11:52:05 -0700
Message-ID: <200806261152.06092.jbarnes@virtuousgeek.org>
References: <20080625203931.GA32408@gospo.rdu.redhat.com> <20080626024040.GB32408@gospo.rdu.redhat.com> <20080625.194322.195953643.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, matthew@wil.cx, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080625.194322.195953643.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 25, 2008 7:43 pm David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 25 Jun 2008 22:40:40 -0400
>
> > For the poll_controller routines (which is what this patch is about),
> > quite a few do (bnx2, bnx2x, b44, e1000, and e1000e to name a few).
> >
> > Much like the other drivers for Intel hardware, the function with
> > 'netpoll' in the name is used for the poll_controller routine whereas
> > the napi poll routines all have 'clean' in the name.
>
> Thanks for the clarification.
>
> I'm still curious what the deadlock case is.  It might be something
> we should fix elsewhere too.

I'm curious too... Also, won't using disable_irq() rather than a device 
specific method break the shared irq case?  It looks like free_irq() handles 
that, but not disable_irq().

Jesse
