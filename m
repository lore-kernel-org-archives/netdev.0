From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] igb: completely disable interrupts during netpoll
Date: Wed, 25 Jun 2008 19:43:22 -0700 (PDT)
Message-ID: <20080625.194322.195953643.davem@davemloft.net>
References: <20080625203931.GA32408@gospo.rdu.redhat.com>
	<20080625.172911.189232903.davem@davemloft.net>
	<20080626024040.GB32408@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: matthew@wil.cx, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: andy@greyhouse.net
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080626024040.GB32408@gospo.rdu.redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>
Date: Wed, 25 Jun 2008 22:40:40 -0400

> For the poll_controller routines (which is what this patch is about),
> quite a few do (bnx2, bnx2x, b44, e1000, and e1000e to name a few).
> 
> Much like the other drivers for Intel hardware, the function with
> 'netpoll' in the name is used for the poll_controller routine whereas
> the napi poll routines all have 'clean' in the name.

Thanks for the clarification.

I'm still curious what the deadlock case is.  It might be something
we should fix elsewhere too.
