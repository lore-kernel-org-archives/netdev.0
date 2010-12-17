From: Bjorn Helgaas <bjorn.helgaas@hp.com>
Subject: Re: "x86: allocate space within a region top-down" causes bar0 access issue
Date: Fri, 17 Dec 2010 13:16:12 -0700
Message-ID: <201012171316.12761.bjorn.helgaas@hp.com>
References: <20101217194457.GA4470@exar.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ramkrishna Vepa <ramkrishna.vepa@exar.com>
To: Jon Mason <jon.mason@exar.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101217194457.GA4470@exar.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, December 17, 2010 12:44:58 pm Jon Mason wrote:
> The following patch is causing problem with the vxge driver/adapter on
> HP x86-64 systems. Reads to bar0 to return 0xffffffffffffffff instead
> of their intended value.  This prevents the vxge module from loading
> by failing sanity checks in the driver for certain values in bar0.  We
> are not seeing any issues with this patch on non-HP systems in our
> lab.
> 
> Can this patch be removed from 2.6.37 until a better solution can be
> found?

There were several issues related to that patch, and it's about to
be reverted.  I am curious about the failure you're seeing, though,
and I'd like to understand the cause and make sure it's one of the
issues I've already investigated.

Can you send me the complete dmesg log of a failing boot?

Thanks,
  Bjorn
