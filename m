From: Nils Holland <nholland@tisys.org>
Subject: Re: [PATCH net]tg3: tg3_disable_ints using uninitialized mailbox
 value to disable interrupts
Date: Sat, 20 Dec 2014 23:16:07 +0100
Message-ID: <20141220221606.GA2591@teela.fritz.box>
References: <1419106577-12891-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, marcelo.leitner@gmail.com,
	bhelgaas@google.com, rajatxjain@gmail.com,
	Michael Chan <mchan@broadcom.com>
To: Prashant Sreedharan <prashant@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1419106577-12891-1-git-send-email-prashant@broadcom.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 20, 2014 at 12:16:17PM -0800, Prashant Sreedharan wrote:
> 
> This driver bug was exposed because of the commit a7877b17a667 (PCI: Check only
> the Vendor ID to identify Configuration Request Retry). Also this issue is only
> seen in older generation chipsets like 5722 because config space write to offset
> 0 from driver is possible.
> 
> Fixed by initializing the interrupt mailbox registers before calling tg3_halt.
> 
> Please queue for -stable.

I gave this patch a try and can confirm what was to be expected: It
fixes the issue and the network interface is once again working
properly on my system. Thus, I guess the issue is adequately solved.

Thanks to everyone involved, especially to Marcelo for additional
debugging and the guys at Broadcom for the quick fix!

Greetings,
Nils
