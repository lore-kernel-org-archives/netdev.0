From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 1/2] [PCI] Check that MWI bit really did get set
Date: Sun, 15 Oct 2006 19:07:08 -0700
Message-ID: <200610151907.09991.david-b@pacbell.net>
References: <1160161519800-git-send-email-matthew@wil.cx> <17714.54766.390707.532248@cargo.ozlabs.ibm.com> <20061015181044.ec414e4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus@samba.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, matthew@wil.cx,
	val_henson@linux.intel.com, netdev@vger.kernel.org,
	linux-pci@atrey.karlin.mff.cuni.cz, linux-kernel@vger.kernel.org,
	gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.sbc.mail.mud.yahoo.com ([68.142.198.200]:42649 "HELO
	smtp101.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751298AbWJPCHO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 Oct 2006 22:07:14 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20061015181044.ec414e4f.akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 15 October 2006 6:10 pm, Andrew Morton wrote:

> - A printk if something went bad

Where "bad" would I hope exclude cases where the device
doesn't support MWI ... that is, the "go faster if you can"
advice from the driver, where it isn't an error to run into
the common case of _this_ implementation not happening to
be able to issue MWI cycles.

The other cases, where something actually went wrong, would
be reasonable for emitting KERN_ERR or KERN_WARNING messages.

- Dave

