From: Jingoo Han <jg1.han@samsung.com>
Subject: Re: [PATCH 20/39] net: remove DEFINE_PCI_DEVICE_TABLE macro
Date: Tue, 03 Dec 2013 11:44:16 +0900
Message-ID: <004601ceefd1$8efd6ea0$acf84be0$%han@samsung.com>
References: <001501ceefb1$69c96820$3d5c3860$%han@samsung.com>
 <002901ceefb4$f1191e30$d34b5a90$%han@samsung.com>
 <20131202183646.459564a9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: 'Greg Kroah-Hartman' <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, 'David Miller' <davem@davemloft.net>,
	netdev@vger.kernel.org, 'Joe Perches' <joe@perches.com>,
	'Jonas Bonn' <jonas@southpole.se>,
	'Jingoo Han' <jg1.han@samsung.com>
To: 'Stephen Hemminger' <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20131202183646.459564a9@nehalam.linuxnetplumber.net>
Content-language: ko
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, December 03, 2013 11:37 AM, Stephen Hemminger wrote:
> On Tue, 03 Dec 2013 08:19:25 +0900
> Jingoo Han <jg1.han@samsung.com> wrote:
> 
> > Don't use DEFINE_PCI_DEVICE_TABLE macro, because this macro
> > is not preferred.
> >
> > Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> 
> Perhaps a little more explanation why it is not preferred.
> Not everyone tracks LKML or the PCI list.

(+cc Joe Perches, Jonas Bonn)

It is simple.
There is no special reason to use DEFINE_PCI_DEVICE_TABLE macro.

According to the Greg Kroah-Hartman,
"Yeah, and it's a horrid macro that deserves to be removed,
please don't use it in more places."

Currently, there is no other bus that has something like this
macro for their device ids. Thus, DEFINE_PCI_DEVICE_TABLE macro
should be removed.

Jonas Bonn (author of DEFINE_PCI_DEVICE_TABLE macro) also agreed
to remove this macro. According to Jonas Bonn,
"Actually, I think I submitted an even uglier macro called 
DECLARE_PCI_DEVICE_TABLE... might have been the first kernel
Patch I  ever sent?  In any case, it should certainly have been
kindly rejected."

After Joe Perches's patch[1] is merged, I will send these patches
to each subsystem maintainer.

[1][PATCH] pci/checkpatch: Deprecate DEFINE_PCI_DEVICE_TABLE
    (http://lkml.org/lkml/2013/12/2/400)

In this patch, Joe Perches fixed 'Documentation/PCI/pci.txt', and
'scripts/checkpatch.pl', in order to guide to use 'struct pci_device_id'
instead of 'DEFINE_PCI_DEVICE_TABLE' macro.

Thank you.

Best regards,
Jingoo Han
