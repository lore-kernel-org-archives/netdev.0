From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: "x86: allocate space within a region top-down" causes bar0
 access issue
Date: Fri, 17 Dec 2010 11:47:21 -0800
Message-ID: <20101217114721.04eafeca@jbarnes-desktop>
References: <20101217194457.GA4470@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bjorn Helgaas <bjorn.helgaas@hp.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: Jon Mason <jon.mason@exar.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101217194457.GA4470@exar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 17 Dec 2010 13:44:58 -0600
Jon Mason <jon.mason@exar.com> wrote:

> The following patch is causing problem with the vxge driver/adapter on
> HP x86-64 systems. Reads to bar0 to return 0xffffffffffffffff instead
> of their intended value.  This prevents the vxge module from loading
> by failing sanity checks in the driver for certain values in bar0.  We
> are not seeing any issues with this patch on non-HP systems in our
> lab.
> 
> Can this patch be removed from 2.6.37 until a better solution can be
> found?

Can you try my for-linus branch and see if the problem still exists
there?  It's at
git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6.git.

Thanks,
-- 
Jesse Barnes, Intel Open Source Technology Center
