From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH/REPOST] pci: push deprecated pci_find_device() function
 to last user
Date: Fri, 15 Jan 2010 10:08:30 -0800
Message-ID: <20100115100830.152bd145@jbarnes-piketon>
References: <20100113142328.5DE2F40107@xenon.ts.pxnet.com>
	<20100113.203338.52448956.davem@davemloft.net>
	<20100114044331.GA29008@suse.de>
	<20100114.001204.203918209.davem@davemloft.net>
	<20100114082823.63379b3d@jbarnes-piketon>
	<20100114221841.D282640108@xenon.ts.pxnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Greg KH <gregkh@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757929Ab0AOSIa@vger.kernel.org>
In-Reply-To: <20100114221841.D282640108@xenon.ts.pxnet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Jan 2010 23:18:41 +0100 (CET)
Tilman Schmidt <tilman@imap.cc> wrote:

> Am 14.01.2010 17:28 schrieb Jesse Barnes:
> > I can take it, but I lost the original patch.  Tilman, can you
> > resend?
> 
> Sure, here you are:
> 
> Subject: [PATCH] pci: push deprecated pci_find_device() function to
> last user
> 
> The ISDN4Linux HiSax driver family contains the last remaining users
> of the deprecated pci_find_device() function. This patch creates a
> private copy of that function in HiSax, and removes the now unused
> global function together with its controlling configuration option,
> CONFIG_PCI_LEGACY.
> 
> Impact: code reorganization, no functional change
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> ---
> Note: This patch is not, nor does it intend to be, checkpatch.pl
> clean. The issues checkpatch.pl reports on it were already present
> before, and are unrelated to the topic of this patch.

Applied to my linux-next branch, thanks Tilman.

-- 
Jesse Barnes, Intel Open Source Technology Center
