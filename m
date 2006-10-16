From: David Brownell <david-b@pacbell.net>
Subject: Re: [Bulk] Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Sun, 15 Oct 2006 17:21:53 -0700
Message-ID: <200610151721.54873.david-b@pacbell.net>
References: <1160161519800-git-send-email-matthew@wil.cx> <20061015104544.5de31608.akpm@osdl.org> <17714.52121.962807.781244@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Matthew Wilcox <matthew@wil.cx>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.sbc.mail.mud.yahoo.com ([68.142.198.204]:54443 "HELO
	smtp105.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1161184AbWJPAV6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 20:21:58 -0400
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <17714.52121.962807.781244@cargo.ozlabs.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > If the drivers doesn't care and if it makes no difference to performance
> > then just delete the call to pci_set_mwi().
> > 
> > But if MWI _does_ make a difference to performance then we should tell
> > someone that it isn't working rather than silently misbehaving?

To repeat:  it's not "misbehaving" since support for MWI cycles is
completely optional.  It'd be more interesting to get messages in
the cases that it can be enabled, since typically it can't be.


> That sounds like we need a printk inside pci_set_mwi then, rather than
> adding a printk to every single caller.

Maybe wrapped in #ifdef CONFIG_SPAM_MY_KERNEL_LOG_MESSAGES ... :)

