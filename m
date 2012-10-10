From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 0/2] PCI-Express Non-Transparent Bridge Support
Date: Wed, 10 Oct 2012 11:05:32 -0700
Message-ID: <1349892332.3776.269.camel@haakon2.linux-iscsi.org>
References: <1349213177-9985-1-git-send-email-jon.mason@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Bjorn Helgaas <bhelgaas@google.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349213177-9985-1-git-send-email-jon.mason@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jon & Co,

On Tue, 2012-10-02 at 14:26 -0700, Jon Mason wrote:
> I am submitting version 4 of the PCI-Express Non-Transparent Bridge
> patches for inclusion in 3.7.  All outstanding issues from the RFC
> process have been addressed.
> 
> version 1
> http://thread.gmane.org/gmane.linux.kernel.pci/16443
> 
> Version 2 incorporates numerous clean-ups 
> http://thread.gmane.org/gmane.linux.kernel.pci/16696
> 
> Version 3 incorporates changes to conform NTB and client devices to the
> Linux device model (per Greg KH's request).
> http://thread.gmane.org/gmane.linux.kernel.pci/17808
> 
> Version 4 removes the transport transmit tasklet (per Dave Miller's
> request).
> http://thread.gmane.org/gmane.linux.network/244491
> 

I'm very happy with the current state of the new NTB subsystem code for
an initial merge.

As we are t-minus ~5 days until the v3.7 merge window closes, you'll
want to (very soon) be sending a PULL request to Linus for drivers/ntb/
with the appropriate Reviewed-By's + Acked-By's in place.

--nab
