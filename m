From: Roland Dreier <rdreier@cisco.com>
Subject: Re: howto use ioremap_wc?
Date: Wed, 04 Jun 2008 21:53:54 -0700
Message-ID: <adad4mw1nz1.fsf@cisco.com>
References: <4841143E.5080003@myri.com>
	<20080531185424.1cd18220@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brice Goglin <brice@myri.com>, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"venkatesh.pallipadi\@intel.com" <venkatesh.pallipadi@intel.com>
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:16418 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751241AbYFEEyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 00:54:45 -0400
In-Reply-To: <20080531185424.1cd18220@infradead.org> (Arjan van de Ven's
	message of "Sat, 31 May 2008 18:54:24 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This thread reminds me of another question about interfaces for using
PAT.  Are there any plans for making pgprot_writecombine() a generic
interface that portable drivers can use to map PCI memory into userspace
with WC turned on?  (Falling back to uncached when WC is not available
for whatever reason is fine for the case I have in mind)

Maybe it's better to ask at a higher level: what's the right thing for a
driver to do in an mmap method when it wants to expose PCI memory to
userspace with WC turned on if possible?  I see that the PCI sysfs code
on x86 does it using non-exported (hence not available to a driver
buildable as a module) interfaces.

Thanks,
  Roland
