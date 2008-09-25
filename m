From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH 1/9] PCI: vpd handle longer delays in access (rev3)
Date: Thu, 25 Sep 2008 12:54:26 -0600
Message-ID: <20080925185426.GT27204@parisc-linux.org>
References: <20080925164851.694359776@vyatta.com> <20080925165223.168847327@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	Ivan Vecera <ivecera@redhat.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20080925165223.168847327@vyatta.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 25, 2008 at 09:48:52AM -0700, Stephen Hemminger wrote:
> +		if(!cond_resched())

Style nit (did you run checkpatch?)

I think I've commented on the previous versions of this patch enough for
it to be worth adding:

Reviwed-by: Matthew Wilcox <willy@linux.intel.com>

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
